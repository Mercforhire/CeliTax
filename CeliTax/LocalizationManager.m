//
//  LocalizationManager.m
//  CeliTax
//
//  Created by Leon Chen on 2015-09-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "LocalizationManager.h"
#import "Notifications.h"

#define kKeyLanguage                @"Language"

@implementation Language

- (NSString *) description
{
    NSMutableString *desc = [NSMutableString string];
    
    [desc appendFormat: @"code: %@, ", self.code];
    [desc appendFormat: @"display: %@, ", self.display];
    
    return desc;
}

@end

@interface LocalizationManager ()

@property (nonatomic, strong) NSDictionary *baseStrings;
@property (nonatomic, strong) NSMutableArray *supportedLanguages;
@property (nonatomic, strong) Language *currentLanguage;

@end

@implementation LocalizationManager

+ (LocalizationManager *) sharedInstance
{
    static dispatch_once_t once;
    static LocalizationManager *sharedInstance;
    
    dispatch_once(&once, ^()
                  {
                      sharedInstance = [[self alloc] init];
                  });
    
    return sharedInstance;
}

- (void) initialize
{
    // Grab the languages from the PL and build what we need...
    [self initSupportedLanguages];
    
    // Get the last set language
    NSString *langPref = [[NSUserDefaults standardUserDefaults] objectForKey: kKeyLanguage];
    
    if (langPref)
    {
        // Found one, use it...
        DLog(@"Using user selected language: %@", langPref);
        
        [self changeLanguage: langPref];
    }
    else
    {
        // Didn't find one, let's check the device settings then...
        NSString *systemLang = [[NSLocale preferredLanguages] objectAtIndex: 0];
        
        if ([self isLanguageSupported: systemLang])
        {
            // That language is supported, use it...
            DLog(@"Using user system language: %@", systemLang);
            
            [self changeLanguage: systemLang];
        }
        else
        {
            // Not supported, fallback to the first language
            DLog(@"Using user default language: %@", @"en");
            
            [self changeLanguage: ((Language *) [self.supportedLanguages firstObject]).code];
        }
    }
}

- (void) initSupportedLanguages
{
    NSArray *supportedLanguageCodes = [[NSArray alloc] initWithObjects:@"en", @"fr", @"es", nil];
    
    self.supportedLanguages = [NSMutableArray array];
    
    for (NSString *code in supportedLanguageCodes)
    {
        Language *language = [[Language alloc] init];
        
        [self initializeLanguage: language forCode: code];
        
        [self.supportedLanguages addObject: language];
    }
}

- (void) initializeLanguage: (Language *) language forCode: (NSString *) code
{
    if ([code isEqualToString: @"en"])
    {
        language.code = @"en";
        language.display = @"English";
    }
    else if ([code isEqualToString: @"fr"])
    {
        language.code = @"fr";
        language.display = @"French";
    }
    else if ([code isEqualToString: @"es"])
    {
        language.code = @"es";
        language.display = @"Spanish";
    }
}

- (void) reloadSupportedLanguages
{
    for (Language *language in self.supportedLanguages)
    {
        [self initializeLanguage: language forCode: language.code];
    }
}

- (BOOL) isLanguageSupported: (NSString *) language
{
    for (Language *supportedLanguage in self.supportedLanguages)
    {
        if ([supportedLanguage.code isEqualToString: language])
        {
            return YES;
        }
    }
    
    return NO;
}

- (Language *) findLanguage: (NSString *) language
{
    for (Language *supportedLanguage in self.supportedLanguages)
    {
        if ([supportedLanguage.code isEqualToString: language])
        {
            return supportedLanguage;
        }
    }
    
    return [self.supportedLanguages firstObject];
}

- (void) changeLanguage: (NSString *) language
{
    [self changeLanguage: language force: NO];
}

- (void) changeLanguage: (NSString *) language force: (BOOL) force
{
    if ([language isEqualToString: self.currentLanguage.code] && !force)
    {
        return;
    }
    
    if (![self isLanguageSupported: language])
    {
        DLog(@"%@ is not supported, defaulting to %@", language, @"en");
        
        language = @"en";
    }
    
    // Grab the correct strings based on the new language...
    [self findStrings: language];
    
    // Force a reload of the language text in the new language so that in memory language objects get the right text...
    [self reloadSupportedLanguages];
    
    self.currentLanguage = [self findLanguage: language];
    
    DLog(@"Setting language to %@", language);
    
    // Save this as the last set language for the pl...
    [[NSUserDefaults standardUserDefaults] setObject: language forKey: kKeyLanguage];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Let the world know that they need to deal with this change...
    [[NSNotificationCenter defaultCenter] postNotificationName: kAppLanguageChangedNotification object: self];
}

- (void) findStrings: (NSString *) language
{
    NSMutableString *defaultName = [NSMutableString stringWithString: @"Localizable"];
    NSMutableString *fullName = [NSMutableString stringWithFormat: @"%@", defaultName];
    
    [fullName appendFormat: @"_%@", language];
    
    NSString *path = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: fullName, language] ofType: @"strings"];
    
    if (!path)
    {
        // Default back to the base file if nothing was found
        path = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: defaultName, language] ofType: @"strings"];
    }
    
    self.baseStrings = [NSDictionary dictionaryWithContentsOfFile: path];
}


- (NSString *) localizedStringForKey: (NSString *) key value: (NSString *) value table: (NSString *) tableName
{
    // we check the base string file
    NSString *string = [self.baseStrings objectForKey: key];
    
    if (string)
    {
        return string;
    }
    
    DLog(@"Missing translation key: '%@'. Please add it to the all of the strings files.", key);
    
    // If we didn't find anything, just return the key
    return key;
}

@end
