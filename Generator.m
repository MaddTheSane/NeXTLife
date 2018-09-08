#include <sys/types.h>
#include <sys/dir.h>

#import "Generator.h"
#import "InfoGenerator.h"
#import "PrefController.h"
#import "RandomGenerator.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import "Mail.h"

#define MAXFILES 32
#define MAXNAME 128

@interface Generator () <SBApplicationDelegate>
@end


static inline void swap( char *v[], int i, int j);

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
static inline void swap( char *v[], int i, int j)
{
	char *temp;
	
	temp = v[i];
	v[i] = v[j];
	v[j] = temp;
}

@implementation Generator {
	NSMutableArray *nibObjects;
}
@synthesize lifeView;
@synthesize filename;
@synthesize generation;

- (instancetype)init
{
	self = [super init];
	nibObjects = [[NSMutableArray alloc] init];
	running = NO;	
	speed = 0.1;	/* initial value for TE speed */
	return self;
}

- (void)awakeFromNib
{
	if(menuLoaded == NO) { 				//load Samples once only!
		NSBundle	*theBundle = [NSBundle mainBundle];
		NSString *sampleDir = @"LifeSamples";
		NSString *theDir;
	
		theDir = [[theBundle resourcePath] stringByAppendingPathComponent:sampleDir];
		
		[self loadSamplesMenuFromDirectory:theDir];
	
		menuLoaded = YES;
	}
}

/* the clear method has to get the Universe size (IntNXSize) from lifeView
 * to know the population array size.
 * we also stop the animation if running.
 */
- (IBAction)clear:(id)sender
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
	
	[self setFilename:@"\0"];
	
	generation = 0;					/* zero the generation number	*/
	[generationField setIntValue:generation];
	
	free(population);
}

/* dual purpose method that gets called from the run button. the button
 * alternate name to stop and the BOOL running keeps track.
 */
- (IBAction)runStop:(id)sender
{
	if(!running) {
		running = YES;
		[runButton setState: YES];
		[runMenuButton setTitle:@"Stop"];
		/* the Timed entry calls the handler ... */
		runningTE = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(go) userInfo:nil repeats:YES];
		//runningTE = DPSAddTimedEntry(speed,&handler,
		//			self,NX_BASETHRESHOLD);
	} else {
		[self removeTE];
		running = NO;
		[runButton setState: NO];
		[runMenuButton setTitle:@"Run"];
	}
}

- (IBAction)step:(id)sender
{
	/* calculate and display the next generation */
	[lifeView calculate];
	[lifeView display];
	/* and remember to increment the generation number */
	[generationField setIntegerValue:(++generation)];
}

- (void)setFilename:(NSString *)aFilename
{
	filename = [aFilename copy];
	[filenameField setStringValue:[filename lastPathComponent]];
}

- (IBAction)saveAs:(id)sender
{
	NSSavePanel *savePanel;
	NSString *dir;
	NSString *file;
	
	if (filename==nil) {
		dir = NSHomeDirectory();
		file = [filenameField stringValue];
	} else {
		file = [filename lastPathComponent];
		if (file) {
			dir = filename;
		} else {
			dir = [filename stringByDeletingLastPathComponent];
			file = [filenameField stringValue];
		}
	}
	savePanel = [NSSavePanel savePanel];
	savePanel.allowedFileTypes = @[@"life"];
	savePanel.directoryURL = [NSURL fileURLWithPath:dir];
	if (file) {
		savePanel.nameFieldStringValue = file;
	}
	
	if ([savePanel runModal] == NSFileHandlingPanelOKButton) {
		[self setFilename:[[savePanel URL] path]];
		[self save:sender];
	}
}

- (IBAction)save:(id)sender
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

- (IBAction)load:(id)sender
{
	NSOpenPanel	*openPanel;
	
	openPanel = [NSOpenPanel openPanel];
	openPanel.allowsMultipleSelection = NO;
	openPanel.allowedFileTypes = @[@"life"];
	
	if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
		[self setFilename:[[openPanel URL] path]];
		[self loadFile:filename];
	}
}

- (BOOL)loadFile:(NSString *)aFilename
{
	FILE *fp;
	char *population;
	int	popSize;
	int	i,position;
	IntNXSize theUniverse;
	BOOL retVal = YES;
	
	fp = fopen([aFilename fileSystemRepresentation],"r");
	if (fp==NULL) {
		NSRunAlertPanel(@"Error", @"Cannot open file: %s", 0, 0, 0, strerror(errno));
		return NO;
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
			fclose(fp);
			retVal = NO;
		}
		[lifeView showPopulation:population ofSize:popSize
					 andUniverse:theUniverse];
		free(population);
	}
	else {
		NSRunAlertPanel(0, @"Formar error in opened file: No Sizes.",0,0,0);
		retVal = NO;
	}
	fclose(fp);
	generation = 0;
	[generationField setIntegerValue:generation];
	return retVal;
}

- (IBAction)loadSample:(id)sender
{
	NSString	*file;
	NSString 	*title   = [[sender selectedCell] title];
	NSString 	*theMainDir  = [[NSBundle mainBundle] resourcePath];
	NSString 	*samplesDir  = @"LifeSamples";
	NSString	*filetype = @"life";
	
	file = [[[theMainDir stringByAppendingPathComponent:samplesDir] stringByAppendingPathComponent:title] stringByAppendingPathExtension:filetype];
	
	self.filename = file;
	[self loadFile:filename];
	
}

- (IBAction)revertToSaved:(id)sender
{
	NSInteger q;
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
	return;
}

/* the method that sits inside the TimedEntry so that it will execute untill
 * we click runStop (or clear). The NXPing() is to syncronise with the server 
 * so that the time between generation will be close to constant.
 */
- (void)go
{
	[self step:nil];
	//NXPing();			//synchronize with server
}

- (void)removeTE
{
	if (runningTE) {
		[runningTE invalidate];
		runningTE = nil;				/* have to actually remove it */
	}
}

- (IBAction)showInfo:(id)sender
{
	
	NSString *file = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"life"];
	
	if (!infoGenerator) {
		NSArray *tmpObj;
		[[NSBundle mainBundle] loadNibNamed:@"InfoPanel" owner:self topLevelObjects:&tmpObj];
		if (tmpObj != nil) {
			[nibObjects addObjectsFromArray:tmpObj];
		}
	}
	[ [infoGenerator window] makeKeyAndOrderFront:sender];
	
	[infoGenerator resetSpeed:0.1];
	
	[infoGenerator loadFile:file];
	if(!running) {
		[infoGenerator runStop:nil];
	}
}

- (IBAction)showLegal:(id)sender
{
	if (!infoGenerator) {
		NSArray *tmpObj;
		[[NSBundle mainBundle] loadNibNamed:@"InfoPanel" owner:self topLevelObjects:&tmpObj];
		if (tmpObj != nil) {
			[nibObjects addObjectsFromArray:tmpObj];
		}
	}
	[ [infoGenerator panel] makeKeyAndOrderFront:sender];
}

- (IBAction)showPrefs:(id)sender
{
	if (!prefController) {
		NSArray *tmpObj;
		[[NSBundle mainBundle] loadNibNamed:@"Preferences" owner:self topLevelObjects:&tmpObj];
		if (tmpObj != nil) {
			[nibObjects addObjectsFromArray:tmpObj];
		}
	}
	[ [prefController window] makeKeyAndOrderFront:sender];
}

- (IBAction)startRandomTool:(id)sender
{
	if (!randomGenerator) {
		NSArray *randNibObjs = nil;
		[[NSBundle mainBundle] loadNibNamed:@"Random" owner:self topLevelObjects:&randNibObjs];
		if (randNibObjs != nil) {
			[nibObjects addObjectsFromArray:randNibObjs];
		}
	}
	[ [randomGenerator window] makeKeyAndOrderFront:sender];
}



- (void)loadSamplesMenuFromDirectory:(NSString *)aDirectory
{
	DIR *dp;				/* pointer to DIR */
	struct	direct *dirp;	/* pointer to dirent structure */
	int i = 0;
	int	j;
	NSInteger q;
	char *file,name[MAXNAME];		/* to hold the file name currently read */
	char *afterDot;		/* to hold the extension. Is it the same as "life" */
	char *fileList[MAXFILES];	/* holds the list of files to sort */
	const char *fileType = ".life";
	
	if( (dp = opendir([aDirectory fileSystemRepresentation])) == NULL ) {
		q = NSRunAlertPanel(@"Sample Menu",
			@"Cannot open Samples directory %@.",
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
		[self addSampleMenuCell:@(*(fileList+j)) ];
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
	NSMenuItem *ite= [samplesMenu addItemWithTitle:aTitle action:@selector(loadSample:) keyEquivalent:@""];
	ite.target = self;
}

/* the speed slider will do this. */
- (IBAction)setSpeed:(id)sender
{
	speed = [sender doubleValue];
	/* do runStop twice so we get to the  same state (running or not) as
	 * before the runStop
	 */
	[self runStop:nil];
	[self runStop:nil];
}

- (IBAction)resetSizeTo:(IntNXSize)aSize
{
	IntNXSize	theUniverse = [lifeView universe];
	NSInteger q;
	
	if((theUniverse.width == aSize.width)&&(theUniverse.height == 
						aSize.height)) {
		return;
	}
	else {
		if([lifeView popSize] != 0) {
			q = NSRunAlertPanel(@"Resize",
				@"Resizing will discard current configuration. Resize?",
				@"Yes", @"Cancel", 0);
		} else {
			q = NSAlertDefaultReturn;
		}
	}
	
	if(q == NSAlertDefaultReturn) {
		[self clear:nil];
		[lifeView setUniverse:aSize];
		[self clear:nil];
	}
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	//free(lifeView);
	//free(infoGenerator);
}

/* This is pretty much lifted from Game Kit. He said it's lifted from
 * opener
 */
- (IBAction)suggestion:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];

#define call(a,b) [s performRemoteMethod:a with:b length:strlen(b)+1]

	NSInteger x = 1;
	BOOL doit = NO;
	
	NSString *tmpstr = [defaults stringForKey:@"Mail"];
			
	if (!tmpstr) {
		doit = YES;
	}
	else if ([tmpstr isEqualToString:@"OK"]) {
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
			[defaults setObject:@"OK" forKey:@"Mail"];
				break;
		case NSAlertOtherReturn:
				return;	/* Abort! */
				break;
		default:
				break;
	}
	
	
	[ws launchApplication:@"Mail"]; // make sure app is launched
	MailApplication *mail = [SBApplication applicationWithBundleIdentifier:@"com.apple.Mail"];
	
	/* set ourself as the delegate to receive any errors */
	mail.delegate = self;

	MailOutgoingMessage *emailMessage = [[[mail classForScriptingClass:@"outgoing message"] alloc] initWithProperties:
										 [NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"Comments and Suggestion for \"Life\" (%s)", VERSION_STRING], @"subject",
										  @"Well, here is my Feedback:\n\n", @"content",
										  nil]];

	
	/* add the object to the mail app  */
	[[mail outgoingMessages] addObject: emailMessage];
	
	MailToRecipient *theRecipient = [[[mail classForScriptingClass:@"to recipient"] alloc] initWithProperties:
									 [NSDictionary dictionaryWithObjectsAndKeys:
									  @"gil@atlantic.mps.ohio-state.edu", @"address",
									  nil]];
	[emailMessage.toRecipients addObject: theRecipient];

	if ( [mail lastError] != nil )
		return;
	
	emailMessage.visible = YES;
	
    return;
}

- (id) eventDidFail:(const AppleEvent *)event withError:(NSError *)error;
{
	return nil;
}

- (void)dealloc
{
	[self removeTE];
}

/* this and the next method are for opening files directly from the Workspace
 * manager.
 */
- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename1
{
	self.filename = filename1;
	return [self loadFile:filename1];
}
/*
- (BOOL)appAcceptsAnotherFile:(id)sender
{
	return YES;
}

- (int)app:(id)sender openFile:(const char *)aFilename type:(const char *)AType
{
	[self setFilename:aFilename];
	[self loadFile:filename];
	return YES;
}
*/

@end
