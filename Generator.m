
#import "Generator.h"
#import "InfoGenerator.h"
#import <sys/types.h>
#import <sys/dir.h>

#define MAXFILES 32
#define MAXNAME 128

/* the handler for the TimedEntry. the method go calls the stepping.
 */
void handler(DPSTimedEntry teNumber, double now, void *userData)
{
	id obj = (id)userData;
	[obj go];
}

/* a quick sort */
void qqsort(char *v[], int left, int right)
{
	int i, last;
	void swap(char *v[], int i, int j);
	
	if (left >= right) {
		return;
	}
	swap(v, left, (left+right)/2);
	last = left;
	for (i = left +1; i<= right; i++) {
		if (strcmp(v[i], v[left]) < 0) {
			swap(v, ++last, i);
		}
	}
	swap(v, left, last);
	qqsort(v, left, last-1);
	qqsort(v, last +1, right);
}

/* the swap fot quick sort*/
void swap( char *v[], int i, int j)
{
	char *temp;
	
	temp = v[i];
	v[i] = v[j];
	v[j] = temp;
}

@implementation Generator

- init
{
	[super init];
	running = NO;	
	speed = 0.1;	/* initial value for TE speed */
	return self;
}

- awakeFromNib
{
	if(menuLoaded == NO) { 				//load Samples once only!
		id	theBundle = [NXBundle mainBundle];
		char *sampleDir = "/LifeSamples/";
		char *theDir;
	
		theDir = malloc(strlen([theBundle directory]) + strlen(sampleDir) + 1);
		strcpy(theDir,[theBundle directory]);
		strcat(theDir,sampleDir);
	
		[self loadSamplesMenuFromDirectory:theDir];
	
		free(theDir);
		menuLoaded = YES;
	}
	return self;
}

/* the clear method has to get the Universe size (IntNXSize) from lifeView
 * to know the population array size.
 * we also stop the animation if running.
 */
- clear:sender
{
	int i;
	IntNXSize theUniverse = [lifeView universe];
	char *population;
	
	population = malloc(sizeof(char)*theUniverse.width*theUniverse.height);
	
	if(running) {
		[self runStop:nil];
	}
	for(i=0; i < theUniverse.width*theUniverse.height; i++) {
		population[i] = 0;
	}
	[lifeView showPopulation:population ofSize:0];
	
	[self setFilename:"\0"];
	
	generation = 0;					/* zero the generation number	*/
	[generationField setIntValue:generation];
	
	free(population);
	
    return self;
}

/* dual purpose method that gets called from the run button. the button
 * alternate name to stop and the BOOL running keeps track.
 */
- runStop:sender
{
	if(!running) {
		running = YES;
		[runButton setState: YES];
		[runMenuButton setTitle:"Stop"];
		/* the Timed entry calls the handler ... */
		runningTE = DPSAddTimedEntry(speed,&handler,
					self,NX_BASETHRESHOLD);
	}
	else {
		[self removeTE];
		running = NO;
		[runButton setState: NO];
		[runMenuButton setTitle:"Run"];
	}
    return self;
}

- step:sender
{
	/* calculate and display the next generation */
	[ [lifeView calculate] display];
	/* and remember to increment the generation number */
	[generationField setIntValue:(++generation)];
    return self;
}

- setFilename:(const char *)aFilename
{
	char *shortName;
	const char *longName = aFilename;
	
	if (filename) {
		free(filename);
	}
	filename = malloc(strlen(aFilename) +1);
	strcpy(filename, aFilename);
	shortName = rindex(longName,'/');
	if(shortName){
		shortName++;
		[filenameField setStringValue:shortName]; 
	}
	else {
		[filenameField setStringValue:filename];
	}
	return self;
}

- saveAs:sender
{
	id savePanel;
	const char *dir;
	char *file;
	
	if (filename==0) {
		dir = NXHomeDirectory();
		file = (char *)[filenameField stringValue];
	}
	else {
		file = rindex(filename, '/');
		if(file) {
			dir = filename;
			*file = 0;
			file++;
		}
		else {
			dir = filename;
			file = (char *)[filenameField stringValue];
		}
	}
	savePanel = [SavePanel new];
	
	[savePanel setRequiredFileType:"life"];
	if ([savePanel runModalForDirectory:dir file:file]) {
		[self setFilename: [savePanel filename] ];
		return [self save:sender];
	}
	return nil; /* didn't save! */
}

- save:sender
{
	FILE *fp;
	char *pop;
	int popSize;
	int i;
	IntNXSize theUniverse = [lifeView universe];
	
	if (filename==0) {
		return [self saveAs:sender];
	}
	
	fp = fopen(filename,"w");
	if (fp==NULL) {
		NXRunAlertPanel(0, "Cannot save file: %s", 0, 0, 0, strerror(errno));
		return self;
	}
	
	[lifeView takePopulation:&pop andSize:&popSize];  
	/* write the field size and popsize for future reference */
	fprintf(fp, "%d %d %d\n", theUniverse.width, theUniverse.height, popSize);	
	for(i = 0; i< theUniverse.width*theUniverse.height; i++) {
		if(*(pop+i) == 10) {
			fprintf(fp, "%d\n", i);
		}
	}
	fprintf(fp,"%d\n",-1); 	/* end of file */		
	fclose(fp);
	[self setFilename:filename];  
	return self;
}

- load:sender
{
	id	openPanel;
	char *types[2] = {"life", 0};
	
	openPanel = [OpenPanel new];
	[openPanel allowMultipleFiles:NO];
	
	if ([openPanel runModalForTypes:types]) {
		[self setFilename:[openPanel filename]];
		[self loadFile:filename];
	}
	return self;
}

- loadFile:(const char *)aFilename
{
	FILE *fp;
	char *population;
	int	popSize;
	int	i,position;
	IntNXSize theUniverse;
	
	fp = fopen(aFilename,"r");
	if (fp==NULL) {
		NXRunAlertPanel(0, "Cannot open file: %s", 0, 0, 0, strerror(errno));
		return self;
	}
	
	if(fscanf(fp, "%d %d %d\n", &theUniverse.width, 
							&theUniverse.height, &popSize)) {
		population = malloc(sizeof(char)*theUniverse.width*theUniverse.height);
		for(i=0;i<theUniverse.width*theUniverse.height;i++) {
			population[i] = 0;
		}
		for(i=0;i<popSize;i++) {
			fscanf( fp, "%d\n",&position);
			population[position] = 10;
		}
		fscanf(fp,"%d\n",&position);
		if(position != -1) {
		NXRunAlertPanel(0, "Format error in opened file: EOF not found.",
						0,0,0);
		}
		[lifeView showPopulation:population ofSize:popSize 
									andUniverse:theUniverse];
		free(population);
	}
	else {
		NXRunAlertPanel(0, "Formar error in opened file: No Sizes.",0,0,0);
	}
	fclose(fp);
	generation = 0;
	[generationField setIntValue:generation];
	return self;
}

- loadSample:sender
{
	char *file;
	const char 	*title   = [[sender selectedCell] title];
	const char 	*theMainDir  = [[NXBundle mainBundle] directory];
	char 	*samplesDir  = "/LifeSamples/";
	const char *filetype = ".life";
	
	
	file = malloc(strlen(theMainDir) + strlen(samplesDir) + 
					strlen(title) + strlen(filetype) + 1);
	strcpy(file,theMainDir);			/* make the filename */
	strcat(file,samplesDir);
	strcat(file,title);
	strcat(file,filetype);
	
	[self setFilename:file];
	[self loadFile:filename];	
	
	free(file);					/* malloc -> free! */
	return self;
}

- revertToSaved:sender
{
	int q;
	char *file;
	
	if (filename==0) {
		NXRunAlertPanel("Revert","No file has been saved.",0,0,0);
		return self;
	}
	else {
		file = rindex(filename, '/');
		if(file) {
			q = NXRunAlertPanel("Revert","Revert to %s?", 0, "Cancel", 
					0, filename);
			if(q==NX_ALERTDEFAULT) {
				[self loadFile:filename];
			}
		}
		else {
			NXRunAlertPanel("Revert","No file has been saved.",0,0,0);
			return self;
		}
	}
	return self;
}

/* the method that sits inside the TimedEntry so that it will execute untill
 * we click runStop (or clear). The NXPing() is to syncronise with the server 
 * so that the time between generation will be close to constant.
 */
- go
{
	[self step:nil];
	NXPing();			//synchronize with server
	return self;
}

- removeTE
{
	if (runningTE) {
		DPSRemoveTimedEntry(runningTE);
		runningTE = 0;				/* have to actually remove it */
	}
	return self;
}

- showInfo:sender
{
	char *file;
	const char 	*title   = "Info";
	const char 	*theMainDir  = [[NXBundle mainBundle] directory];
	char 	*samplesDir  = "/";
	const char *filetype = ".life";
	
	if (!infoGenerator) {
		[NXApp loadNibSection:"InfoPanel.nib" owner:self];
	}
	[ [infoGenerator window] makeKeyAndOrderFront:sender];
	
	[infoGenerator resetSpeed:0.1];
	file = malloc(strlen(theMainDir) + strlen(samplesDir) + 
					strlen(title) + strlen(filetype) + 1);
	strcpy(file,theMainDir);			/* make the filename */
	strcat(file,samplesDir);
	strcat(file,title);
	strcat(file,filetype);
	[infoGenerator loadFile:file];
	if(!running) {
		[infoGenerator runStop:nil];
	}
	free(file);					/* malloc -> free! */
	return self;
}

- showLegal:sender
{
	if (!infoGenerator) {
		[NXApp loadNibSection:"InfoPanel.nib" owner:self];
	}
	[ [infoGenerator panel] makeKeyAndOrderFront:sender];
	return self;
}

- showPrefs:sender
{
	if (!prefController) {
		[NXApp loadNibSection:"Preferences.nib" owner:self];
	}
	[ [prefController window] makeKeyAndOrderFront:sender];
	return self;
}

- startRandomTool:sender
{
	if (!randomGenerator) {
		[NXApp loadNibSection:"Random.nib" owner:self];
	}
	[ [randomGenerator window] makeKeyAndOrderFront:sender];
	return self;
}



- loadSamplesMenuFromDirectory:(const char *)aDirectory
{
	DIR *dp;				/* pointer to DIR */
	struct	direct *dirp;	/* pointer to dirent structure */
	int i = 0;
	int	j,q;
	char *file,name[MAXNAME];		/* to hold the file name currently read */
	char *afterDot;		/* to hold the extension. Is it the same as "life" */
	char *fileList[MAXFILES];	/* holds the list of files to sort */
	const char *fileType = ".life";
	
	if( (dp = opendir(aDirectory)) == NULL ) {
		q = NXRunAlertPanel("Sample Menu",
			"Cannot open Samples directory %s.",
						"Continue","Quit",0, aDirectory);
		if ( q == NX_ALERTDEFAULT ) {
			return self;
		}
		else {
			[NXApp terminate:nil];
		}
	}
	for (dirp = readdir(dp); dirp != NULL; dirp = readdir(dp)) {
		strcpy(name,dirp -> d_name);
		file = malloc(sizeof(name)); 	/* we want to get a new pointer */
		strcpy(file,name);
		afterDot = rindex(file, '.');
		if(strcmp(afterDot,fileType) == 0) {
			*afterDot = 0;
			fileList[i++] = file;
		}
		else {
			free(file);
		}
	}
	closedir(dp);

	qqsort(fileList, 0, i-1);
		
	/* make the menu */
	for(j=0;j<i;j++) {
		[self addSampleMenuCell:*(fileList+j) ];
	}
	/* free the mallocated pointers */
	for(j=0;j<i;j++) {
		file = fileList[j];
		free(file);
	}
	return self;
}

/* build the submenu */
- addSampleMenuCell:(char *)aTitle
{
	[ [samplesMenu addItem:aTitle 
			action:@selector(loadSample:) keyEquivalent: '\0']
			setTarget:self];
	return self;
}

/* the speed slider will do this. */
- setSpeed:sender
{
	speed = [sender doubleValue];
	/* do runStop twice so we get to the  same state (running or not) as
	 * before the runStop
	 */	
	[ [self runStop:nil] runStop:nil];	
	return self;
}

- resetSizeTo:(IntNXSize)aSize
{
	IntNXSize	theUniverse = [lifeView universe];
	int q;
	
	if((theUniverse.width == aSize.width)&&(theUniverse.height == 
						aSize.height)) {
		return self;
	}
	else {
		if([lifeView popSize] != 0) {
			q = NXRunAlertPanel("Resize", 
				"Resizing will discard current configuration. Resize?",
				"Yes", "Cancel", 0);
		}
		else {
			q = NX_ALERTDEFAULT;
		}
	}
	
	if(q == NX_ALERTDEFAULT) {
		[self clear:nil];
		[lifeView setUniverse:aSize];
		[self clear:nil];
	}
	return self;
}

- lifeView
{
	return lifeView;
}

- setGeneration:(int)aGeneration
{
	generation = aGeneration;
	return self;
}

- (int)generation
{
	return generation;
}

- appWillTerminate:sender
{
	free(lifeView);
	free(infoGenerator);
	return self;
}

/* This is pretty much lifted from Game Kit. He said it's lifted from
 * opener
 */
- suggestion:sender
{
	char subject[256];
	char body[4096] = "";

#define call(a,b) [s performRemoteMethod:a with:b length:strlen(b)+1]

    id 	s = [NXApp appSpeaker];
	int x = 1;
	int doit = NO;
	
	const char *tmpstr = NXGetDefaultValue("LifeByGR", "Mail");
			
	if (!tmpstr) {
		doit = YES;
	}
	else if (strcmp(tmpstr, "OK")) {
		doit = YES;
	}
	
	if (doit) {
		x = NXRunAlertPanel("Warning",
	"Existing `Compose...' winsow will be erased by a bug in \
NeXTMail. Are you sure you want to do this?",
		"OK", "OK Forever", "Abort"); 
	}
	
	switch (x) {
		case NX_ALERTALTERNATE: 
				NXWriteDefault("LifeByGR", "Mail", "OK");
				break;
		case NX_ALERTOTHER:
				return self;	/* Abort! */
				break;
		default:
				break;
	}
	
	sprintf(body, "Well, here is my Feedback:\n\n");

    NXPortFromName("Mail", NULL); // make sure app is launched
    [[NXApp appSpeaker] setSendPort:NXPortFromName("MailSendDemo", NULL)];

    sprintf(subject,"Comments and Suggestions for ``Life'' (");
    strcat(subject,	VERSION_STRING); 
	strcat(subject, ")");

    call("setTo:", "gil@atlantic.mps.ohio-state.edu");
    call("setSubject:", subject);
    call("setBody:", body);
    
    return self;
}

- free
{
	[self removeTE];
	if(filename) {
		free(filename);
	}
	[super free];
	return self;
}

@end

@implementation Generator(ApplicationDelegate)

/* this and the next method are for opening files directly from the Workspace
 * manager.
 */
- (BOOL)appAcceptsAnotherFile:sender
{
	return YES;
}

- (int)app:sender openFile:(const char *)aFilename type:(const char *)AType
{
	[self setFilename:aFilename];
	[self loadFile:filename];
	return YES;
}


@end