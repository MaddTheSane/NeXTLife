
#import "Generator.h"
#import "InfoGenerator.h"
#import "RandomGenerator.h"
#import "PrefController.h"
#include <sys/types.h>
#include <sys/dir.h>

#define MAXFILES 32
#define MAXNAME 128

/* the handler for the TimedEntry. the method go calls the stepping.
 */
#if 0
void handler(DPSTimedEntry teNumber, double now, void *userData)
{
	id obj = (id)userData;
	[obj go];
}
#endif

static void swap( char *v[], int i, int j);

/* a quick sort */
static void qqsort(char *v[], int left, int right)
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
	self = [super init];
	running = NO;	
	speed = 0.1;	/* initial value for TE speed */
	return self;
}

- (void)awakeFromNib
{
	if(menuLoaded == NO) { 				//load Samples once only!
		NSBundle *theBundle = [NSBundle mainBundle];
		NSString *sampleDir = @"LifeSamples";
		NSString *theDir;
		
		theDir = [theBundle resourcePath];
		theDir = [theDir stringByAppendingPathComponent:sampleDir];
	
		[self loadSamplesMenuFromDirectory:theDir];
	
		menuLoaded = YES;
	}
}

/* the clear method has to get the Universe size (IntNXSize) from lifeView
 * to know the population array size.
 * we also stop the animation if running.
 */
- (IBAction)clear:sender
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
	
	[self setFilename:@""];
	
	generation = 0;					/* zero the generation number	*/
	[generationField setIntValue:generation];
	
	free(population);
}

/* dual purpose method that gets called from the run button. the button
 * alternate name to stop and the BOOL running keeps track.
 */
- (IBAction)runStop:sender
{
	if(!running) {
		running = YES;
		[runButton setState: YES];
		[runMenuButton setTitle:@"Stop"];
		/* the Timed entry calls the handler ... */
		runningTE = [[NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(go) userInfo:nil repeats:YES] retain];
		//runningTE = DPSAddTimedEntry(speed,&handler,
		//			self,NX_BASETHRESHOLD);
	} else {
		[self removeTE];
		running = NO;
		[runButton setState: NO];
		[runMenuButton setTitle:@"Run"];
	}
}

- (IBAction)step:sender
{
	/* calculate and display the next generation */
	[lifeView calculate];
	[lifeView setNeedsDisplay:YES];
	/* and remember to increment the generation number */
	[generationField setIntValue:(++generation)];
}

- (void)setFilename:(NSString *)aFilename
{
	NSString *shortName;
	
	if (filename) {
		[filename release];
	}
	filename = [aFilename copy];
	shortName = [aFilename lastPathComponent];
	if(shortName){
		[filenameField setStringValue:shortName]; 
	} else {
		[filenameField setStringValue:filename];
	}
}

- (IBAction)saveAs:sender
{
	NSSavePanel *savePanel;
	NSString *dir;
	NSString *file;
	
	if (filename==nil) {
		dir = NSHomeDirectory();
		file = [filenameField stringValue];
	} else {
		file = [filename lastPathComponent];
		if(file) {
			dir = filename;
			//file = 0;
			//file++;
		}
		else {
			dir = [filename stringByDeletingLastPathComponent];
			file = [filenameField stringValue];
		}
	}
	savePanel = [NSSavePanel savePanel];
	
	[savePanel setRequiredFileType:@"life"];
	if ([savePanel runModalForDirectory:dir file:file]) {
		[self setFilename: [savePanel filename] ];
		[self save:sender];
		//return [self save:sender];
	}
	//return nil; /* didn't save! */
}

- (IBAction)save:sender
{
	FILE *fp;
	char *pop;
	int popSize;
	int i;
	IntNXSize theUniverse = [lifeView universe];
	
	if (filename==0) {
		return [self saveAs:sender];
	}
	
	fp = fopen([filename fileSystemRepresentation],"w");
	if (fp==NULL) {
		NSRunAlertPanel(0, @"Cannot save file: %s", 0, 0, 0, strerror(errno));
		return;
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
}

- (IBAction)load:sender
{
	NSOpenPanel *openPanel;
	NSArray *types;
	types = [NSArray arrayWithObjects:@"life", nil];
	
	openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	
	if ([openPanel runModalForTypes:types]) {
		[self setFilename:[openPanel filename]];
		[self loadFile:filename];
	}
}

- (void)loadFile:(NSString *)aFilename
{
	FILE *fp;
	char *population;
	int	popSize;
	int	i,position;
	IntNXSize theUniverse;
	
	fp = fopen([aFilename fileSystemRepresentation],"r");
	if (fp==NULL) {
		NSRunAlertPanel(@"", @"Cannot open file: %s", 0, 0, 0, strerror(errno));
		return;
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
		NSRunAlertPanel(0, @"Format error in opened file: EOF not found.",
						0,0,0);
		}
		[lifeView showPopulation:population ofSize:popSize 
									andUniverse:theUniverse];
		free(population);
	}
	else {
		NSRunAlertPanel(0, @"Formar error in opened file: No Sizes.",0,0,0);
	}
	fclose(fp);
	generation = 0;
	[generationField setIntValue:generation];
}

- (IBAction)loadSample:sender
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *file;
	NSString *title   = [[sender selectedCell] title];
	NSString *theMainDir  = [[NSBundle mainBundle] resourcePath];
	NSString *samplesDir  = @"LifeSamples";
	NSString *filetype = @"life";
	
        file = [[theMainDir stringByAppendingPathComponent:samplesDir] stringByAppendingPathComponent:title];
	file = [file stringByAppendingPathExtension:filetype];
	
	[self setFilename:file];
	[self loadFile:filename];	
	
	//[pool drain];
	[pool release];
}

- (IBAction)revertToSaved:sender
{
	int q;
	NSString *file;
	
	if (filename==0) {
		NSRunAlertPanel(@"Revert",@"No file has been saved.",0,0,0);
		return;
	}
	else {
		file = [filename lastPathComponent];
		if(file) {
			q = NSRunAlertPanel(@"Revert",@"Revert to %@?", 0, @"Cancel", 
					0, filename);
			if(q==NSAlertDefaultReturn) {
				[self loadFile:filename];
			}
		}
		else {
			NSRunAlertPanel(@"Revert",@"No file has been saved.",0,0,0);
			return;
		}
	}
}

/* the method that sits inside the TimedEntry so that it will execute untill
 * we click runStop (or clear). The NXPing() is to syncronise with the server 
 * so that the time between generation will be close to constant.
 */
- (void)go
{
	[self step:nil];
	//NXPing();			//synchronize with server
	return;
}

- (void)removeTE
{
	if (runningTE) {
		[runningTE invalidate];
		[runningTE release];
		runningTE = nil;		/* have to actually remove it */
	}
}

- (IBAction)showInfo:sender
{
	NSString	*file;
	NSString 	*title   = @"Info.life";
	NSString 	*theMainDir  = [[NSBundle mainBundle] resourcePath];
	//char 	*samplesDir  = "/";
	//NSString *filetype = @"life";
	
	if (!infoGenerator) {
		[NSBundle loadNibNamed:@"InfoPanel.nib" owner:self];
	}
	[ [infoGenerator window] makeKeyAndOrderFront:sender];
	
	[infoGenerator resetSpeed:0.1];
        file = [theMainDir stringByAppendingPathComponent:title];
	[infoGenerator loadFile:file];
	if(!running) {
		[infoGenerator runStop:nil];
	}
}

- (IBAction)showLegal:sender
{
	if (!infoGenerator) {
		[NSBundle loadNibNamed:@"InfoPanel.nib" owner:self];
	}
	[ [infoGenerator panel] makeKeyAndOrderFront:sender];
}

- (IBAction)showPrefs:sender
{
	if (!prefController) {
		[NSBundle loadNibNamed:@"Preferences.nib" owner:self];
	}
	[ [prefController window] makeKeyAndOrderFront:sender];
}

- (IBAction)startRandomTool:sender
{
	if (!randomGenerator) {
		[NSBundle loadNibNamed:@"Random" owner:self];
		//[[NSApplication sharedApplication] loadNibSection:@"Random.nib" owner:self];
	}
	[ [randomGenerator window] makeKeyAndOrderFront:sender];
}



- (void)loadSamplesMenuFromDirectory:(NSString *)aDirectory
{
	DIR *dp;				/* pointer to DIR */
	struct	direct *dirp;	/* pointer to dirent structure */
	int i = 0;
	int	j,q;
	char *file,name[MAXNAME];		/* to hold the file name currently read */
	char *afterDot;		/* to hold the extension. Is it the same as "life" */
	char *fileList[MAXFILES];	/* holds the list of files to sort */
	const char *fileType = ".life";
	
	if( (dp = opendir([aDirectory fileSystemRepresentation])) == NULL ) {
		q = NSRunAlertPanel(@"Sample Menu",
			@"Cannot open Samples directory %s.",
						@"Continue",@"Quit",0, aDirectory);
		if ( q == NSAlertDefaultReturn ) {
			return;
		}
		else {
			[NSApp terminate:nil];
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
		[self addSampleMenuCell:[NSString stringWithCString:*(fileList+j)] ];
	}
	/* free the mallocated pointers */
	for(j=0;j<i;j++) {
		file = fileList[j];
		free(file);
	}
}

/* build the submenu */
- (void)addSampleMenuCell:(NSString *)aTitle
{
	[ [samplesMenu addItemWithTitle:aTitle 
			action:@selector(loadSample:) keyEquivalent: @""]
			setTarget:self];
}

/* the speed slider will do this. */
- (IBAction)setSpeed:sender
{
	speed = [sender doubleValue];
	/* do runStop twice so we get to the  same state (running or not) as
	 * before the runStop
	 */	
	[self runStop:nil];
	[self runStop:nil];	
}

- (void)resetSizeTo:(IntNXSize)aSize
{
	IntNXSize	theUniverse = [lifeView universe];
	int q;
	
	if((theUniverse.width == aSize.width)&&(theUniverse.height == 
						aSize.height)) {
		return;
	}
	else {
		if([lifeView popSize] != 0) {
			q = NSRunAlertPanel(@"Resize", 
				@"Resizing will discard current configuration. Resize?",
				@"Yes", @"Cancel", 0);
		}
		else {
			q = NSAlertDefaultReturn;
		}
	}
	
	if(q == NSAlertDefaultReturn) {
		[self clear:nil];
		[lifeView setUniverse:aSize];
		[self clear:nil];
	}
}

- lifeView
{
	return lifeView;
}

- (void)setGeneration:(int)aGeneration
{
	generation = aGeneration;
}

- (int)generation
{
	return generation;
}

- (void)appWillTerminate:sender
{
	free(lifeView);
	free(infoGenerator);
}

/* This is pretty much lifted from Game Kit. He said it's lifted from
 * opener
 */
- (IBAction)suggestion:sender
{
	char subject[256];
	char body[4096] = "";

#if 0

#define call(a,b) [s performRemoteMethod:a with:b length:strlen(b)+1]

    id 	s = [NSApp appSpeaker];
	int x = 1;
	int doit = NO;
	
	NSString *tmpstr = NXGetDefaultValue("LifeByGR", "Mail");
			
	if (!tmpstr) {
		doit = YES;
	}
	else if (strcmp(tmpstr, "OK")) {
		doit = YES;
	}
	
	if (doit) {
		x = NSRunAlertPanel(@"Warning",
	@"Existing `Compose...' winsow will be erased by a bug in \
NeXTMail. Are you sure you want to do this?",
		@"OK", @"OK Forever", @"Abort"); 
	}
	
	switch (x) {
		case NSAlertAlternateReturn: 
				NXWriteDefault("LifeByGR", "Mail", "OK");
				break;
		case NSAlertOtherReturn:
				return self;	/* Abort! */
				break;
		default:
				break;
	}
	
	sprintf(body, "Well, here is my Feedback:\n\n");

    NXPortFromName("Mail", NULL); // make sure app is launched
    [[NSApp appSpeaker] setSendPort:NXPortFromName("MailSendDemo", NULL)];

    sprintf(subject,"Comments and Suggestions for ``Life'' (");
    strcat(subject,	VERSION_STRING); 
	strcat(subject, ")");

    call("setTo:", "gil@atlantic.mps.ohio-state.edu");
    call("setSubject:", subject);
    call("setBody:", body);
#else
	NSRunAlertPanel(@"Unsupported", @"Sending mail to request features isn't supported right now", nil, nil, nil);
#endif
}

- (void)dealloc
{
	[self removeTE];
	if(filename) {
		free(filename);
		filename = NULL;
	}
	[super dealloc];
}

/* this and the next method are for opening files directly from the Workspace
 * manager.
 */
- (BOOL)appAcceptsAnotherFile:sender
{
	return YES;
}

- (BOOL)application:(NSApplication*)sender openFile:(NSString*)filename1
{
	[self setFilename:filename1];
	[self loadFile:filename1];
	return YES;
}

@end
