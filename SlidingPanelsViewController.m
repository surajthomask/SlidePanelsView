//
//  SlidingPanelsViewController.m
//
//  Created by Suraj Thomas K on 3/30/15.
//  2015 No Heaven Promised
//

#import "SlidingPanelsViewController.h"

float const kHeaderHeight = 48.0f;

@interface CustomButton : UIButton
{
    
}

@property(nonatomic, readonly) UIImageView *customImage;
@property(nonatomic, readonly) UILabel *customLabel;
@end

@implementation CustomButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self != nil)
    {
        
    }
    return self;
}

- (void)setContentsWithString:(NSString *)string
{
    UIImage *image = [UIImage imageNamed:string];
    
    if(image != nil)
    {
        [_customLabel removeFromSuperview];
        _customLabel = nil;
        if(_customImage == nil)
        {
            _customImage = [[UIImageView alloc] initWithFrame:self.bounds];
            [self addSubview:_customImage];
        }
        
        _customImage.image = image;
    }
    else
    {
        [_customImage removeFromSuperview];
        _customImage = nil;
        if(_customLabel == nil)
        {
            _customLabel = [[UILabel alloc] initWithFrame:self.bounds];
            _customLabel.textColor = [UIColor whiteColor];
            _customLabel.textAlignment = NSTextAlignmentCenter;
            _customLabel.font = [UIFont fontWithName:@"Helvetica" size:self.bounds.size.height * 0.8f];
            [self addSubview:_customLabel];
        }
        
        _customLabel.text = string;
    }
}

- (void)setIsSelectedButton:(BOOL)isSelected
{
    if(_customLabel != nil)
        _customLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, isSelected?1.0f:0.5f, isSelected?1.0f:0.5f);
    if(_customImage != nil)
        _customImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, isSelected?1.0f:0.5f, isSelected?1.0f:0.5f);
}

@end






@protocol SlidingHeaderDataSource <NSObject>

- (int)numberOfItems;
- (NSString *)imageNameForItemAtIndex:(int)index;
- (void)touchedOnHeaderButtonAtIndex:(int)index;

@end

@interface SlidingHeader : UIView
{
    int _numItems;
    
    int _animTargetIndex;
    
    NSMutableArray *_buttons;
}
@property (nonatomic, weak) id<SlidingHeaderDataSource> dataSource;
@property (nonatomic, readwrite) int selectedItemIndex;
@property (nonatomic, readonly) UIImageView *backgroundView;

- (instancetype)initWithFrame:(CGRect)frame andDataSource:(id<SlidingHeaderDataSource>)dataSource;
- (void)layoutSubviewsForNewViewSize:(CGSize)size;
- (void)reloadItems;
@end


@implementation SlidingHeader

- (instancetype)initWithFrame:(CGRect)frame andDataSource:(id<SlidingHeaderDataSource>)dataSource
{
    self = [super initWithFrame:frame];
    
    if(self != nil)
    {
        _dataSource = dataSource;
        
        _selectedItemIndex = 0;
        
        _backgroundView = [[UIImageView alloc] initWithFrame:frame];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_backgroundView];
    }
    
    return self;
}

- (void)reloadItems
{
    for (UIButton *button in _buttons)
    {
        [button removeFromSuperview];
    }
    
    [_buttons removeAllObjects];
    
    _numItems = [_dataSource numberOfItems];
    
    float headerHeight = self.bounds.size.height;
    
    float distance = (self.bounds.size.width - headerHeight)/2.0f;
    
    _buttons = [NSMutableArray array];
    
    for (int i = 0; i < _numItems; i++)
    {
        CustomButton *button = [CustomButton buttonWithType:UIButtonTypeCustom];
        
        button.tag = i;
        
        button.frame = CGRectMake((i - (_selectedItemIndex - 1)) * distance, 0.0f, headerHeight, headerHeight);
        
        NSString *imageName = [_dataSource imageNameForItemAtIndex:i + 1];
        
        [button setContentsWithString:imageName];
        
        [button setIsSelectedButton:(i == _selectedItemIndex)];
        
        [self addSubview:button];
        
        [button addTarget:self action:@selector(touchedOnButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [_buttons addObject:button];
    }
}

- (void)touchedOnButton:(UIButton *)button
{
    [self setSelectedItemIndex:(int)button.tag];
}

- (void)setSelectedItemIndex:(int)selectedItemIndex
{
    _selectedItemIndex = selectedItemIndex;
    
    _animTargetIndex = selectedItemIndex;
    
    [_dataSource touchedOnHeaderButtonAtIndex:_animTargetIndex];
    
    int indexDifference = _animTargetIndex - _selectedItemIndex;
    
    [self animateToIndex:(indexDifference == 0)?@(_selectedItemIndex):@(_selectedItemIndex + (indexDifference/abs(indexDifference)))];
}

- (void)animateToIndex:(NSNumber *)index
{
    int indexDifference = _animTargetIndex - _selectedItemIndex;
    float duration = 0.3f/((indexDifference == 0)?1:abs(indexDifference));
    
    float headerHeight = self.bounds.size.height;
    
    float distance = (self.bounds.size.width - headerHeight)/2.0f;
    
    int itemToSelect = [index intValue];
    
    [UIView animateWithDuration:duration animations:^
     {
         for (int i = 0; i < [_buttons count]; i++)
         {
             CustomButton *button = [_buttons objectAtIndex:i];
             button.frame = CGRectMake((i - (itemToSelect - 1)) * distance, 0.0f, headerHeight, headerHeight);

             [button setIsSelectedButton:(i == _selectedItemIndex)];
         }
     }
                     completion:^(BOOL finished)
     {
         if(itemToSelect == _animTargetIndex)
         {
             _selectedItemIndex = itemToSelect;
         }
         else
         {
             [self animateToIndex:@(itemToSelect+((indexDifference == 0)?1:indexDifference/abs(indexDifference)))];
         }
         
     }];
}

- (void)layoutSubviewsForNewViewSize:(CGSize)size
{
    float headerHeight = size.height;
    
    float distance = (size.width - headerHeight)/2.0f;
    
    for (int i = 0; i < [_buttons count]; i++)
    {
        CustomButton *button = [_buttons objectAtIndex:i];
        button.frame = CGRectMake((i - (_selectedItemIndex - 1)) * distance, 0.0f, headerHeight, headerHeight);
        
        [button setIsSelectedButton:(i == _selectedItemIndex)];
    }
}

@end


#pragma mark -
#pragma mark SlidingPanelsViewController
#pragma mark -

@interface SlidingPanelsViewController () <SlidingHeaderDataSource>
{
    int _numberOfPanels;
    
    SlidingHeader *_headerView;
    
    NSMutableDictionary *_viewControllers;
}

@end

@implementation SlidingPanelsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self != nil)
    {
        [self initializeDefaultParameters];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initializeDefaultParameters];
}

- (void)initializeDefaultParameters
{
    _numberOfPanels = 4;
    
    _viewControllers = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureEvent:)];
    swipeLeftGesture.numberOfTouchesRequired = 1;
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftGesture];

    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureEvent:)];
    swipeRightGesture.numberOfTouchesRequired = 1;
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightGesture];
}

- (int)selectedViewIndex
{
    return _headerView.selectedItemIndex;
}

- (UIViewController *)currentViewController
{
    return [_viewControllers objectForKey:@(self.selectedViewIndex)];
}

- (UIViewController *)previousViewController
{
    return [_viewControllers objectForKey:@(self.selectedViewIndex-1)];
}

- (UIViewController *)nextViewController
{
    return [_viewControllers objectForKey:@(self.selectedViewIndex+1)];
}

- (UIImageView *)headerBackground
{
    return _headerView.backgroundView;
}

- (void)selectViewControllerAtIndex:(int)index
{
    index = (index < 0)?0:index;
    index = (index > [_viewControllers count]-1)?[_viewControllers count]-1:index;
    
    [_headerView setSelectedItemIndex:index];
}

- (void)selectViewController:(UIViewController *)viewController
{
    [_viewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if(viewController == obj)
        {
            [self selectViewControllerAtIndex:[key intValue]];
            *stop = NO;
        }
    }];
}

#pragma mark -
#pragma mark Gestures
- (void)swipeGestureEvent:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if(self.selectedViewIndex < ([_viewControllers count] - 1))
            [_headerView setSelectedItemIndex:self.selectedViewIndex+1];
    }
    else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if(self.selectedViewIndex > 0)
            [_headerView setSelectedItemIndex:self.selectedViewIndex-1];
        
    }
}

#pragma mark -
#pragma mark ViewControllers
- (void)addViewController:(UIViewController *)viewController
{
    if(_headerView == nil)
    {
        [self addHeader];
    }
    
    int index = (int)[_viewControllers count];
    
    CGRect frame = self.view.bounds;
    
    float yPos = _headerView.frame.origin. y + _headerView.frame.size.height;
    
    viewController.view.frame = CGRectMake((index + self.selectedViewIndex) * frame.size.width, yPos, frame.size.width, frame.size.height - yPos);
    
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    if(_headerView == nil)
        [self.view addSubview:viewController.view];
    else
        [self.view insertSubview:viewController.view belowSubview:_headerView];
    
    [self addChildViewController:viewController];
    
    [_viewControllers setObject:viewController forKey:@(index)];
    
    [self updateHeader];
}

- (void)insertViewController:(UIViewController *)viewController atIndex:(int)index
{
    if(index >= [_viewControllers count])
    {
        [self addViewController:viewController];
    }
    else
    {
        CGRect frame = self.view.bounds;
        
        float yPos = _headerView.frame.origin. y + _headerView.frame.size.height;
        
        for (int i = (int)[_viewControllers count] - 1; i >= index ; i--)
        {
            UIViewController *tempVC = [_viewControllers objectForKey:@(i)];
            [_viewControllers setObject:tempVC forKey:@(i+1)];

            tempVC.view.frame = CGRectMake((i + self.selectedViewIndex) * frame.size.width, yPos, frame.size.width, frame.size.height - yPos);
        }
        
        [_viewControllers setObject:viewController forKey:@(index)];
        
        viewController.view.frame = CGRectMake((index + self.selectedViewIndex) * frame.size.width, yPos, frame.size.width, frame.size.height - yPos);
        
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        if(_headerView == nil)
            [self.view addSubview:viewController.view];
        else
            [self.view insertSubview:viewController.view belowSubview:_headerView];
        
        [self addChildViewController:viewController];
        
        [self updateHeader];
    }
}

- (void)removeViewController:(UIViewController *)viewController
{
    __block NSNumber *objectKey = nil;
    [_viewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if(viewController == obj)
        {
            objectKey = (NSNumber *)key;
            [self removeViewControllerAtIndex:[objectKey intValue]];
            *stop = NO;
        }
    }];
}

- (void)removeViewControllerAtIndex:(int)index
{
    UIViewController *vc = [_viewControllers objectForKey:@(index)];
    
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
    
    [_viewControllers removeObjectForKey:@(index)];
    
    CGRect frame = self.view.bounds;
    
    for (int i = index + 1; i <= [_viewControllers count]; i++)
    {
        UIViewController *tempVC = [_viewControllers objectForKey:@(i)];
        if(tempVC == nil)
        {
            [_viewControllers removeObjectForKey:@(i-1)];
        }
        else
        {
            [_viewControllers setObject:tempVC forKey:@(i-1)];

            float yPos = _headerView.frame.origin. y + _headerView.frame.size.height;
            
            tempVC.view.frame = CGRectMake((i - 1 + self.selectedViewIndex) * frame.size.width, yPos, frame.size.width, frame.size.height - yPos);
        }
    }

    [self updateHeader];
}

#pragma mark -
#pragma mark Header
- (void)addHeader
{
    CGRect frame = self.view.bounds;
    frame.size.height = kHeaderHeight;
    _headerView = [[SlidingHeader alloc] initWithFrame:frame andDataSource:self];
    _headerView.backgroundColor = [UIColor grayColor];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_headerView];
}

- (void)updateHeader
{
    if(_headerView == nil)
    {
        [self addHeader];
    }
    
    [_headerView reloadItems];
}

- (int)numberOfItems
{
    return (int)[_viewControllers count];
}

- (NSString *)imageNameForItemAtIndex:(int)index
{
    return [NSString stringWithFormat:@"%d", index];
}

- (void)touchedOnHeaderButtonAtIndex:(int)index
{
    int numViews = (int)[_viewControllers count];
    CGRect frame = self.view.bounds;
    
    [UIView animateWithDuration:0.3f animations:^{
        for (int i = 0; i < numViews; i++)
        {
            UIViewController *viewController = [_viewControllers objectForKey:@(i)];
            
            float yPos = _headerView.frame.origin. y + _headerView.frame.size.height;
            
            viewController.view.frame = CGRectMake((i - index) * frame.size.width, yPos, frame.size.width, frame.size.height - yPos);
        }
    }];
    
    UIViewController *vc = [_viewControllers objectForKey:@(index)];
    [_delegate didSelectViewController:vc atIndex:index];
}

- (void)hideHeaderView:(BOOL)hide animated:(BOOL)animated
{
    if(animated)
    {
        [UIView animateWithDuration:0.3f animations:^{
           
            CGRect frame = _headerView.frame;
            frame.origin.y = hide?-frame.size.height:0.0f;
            _headerView.frame = frame;
        } completion:^(BOOL finished)
        {
            
        }];
        
        for (int i = 0; i < [_viewControllers count]; i++)
        {
            UIViewController *viewController = [_viewControllers objectForKey:@(i)];
            
            CGRect frame = _headerView.frame;
            CGRect viewFrame = viewController.view.frame;
            viewFrame.origin.y = frame.origin.y + frame.size.height;
            viewFrame.size.height = self.view.bounds.size.height - viewFrame.origin.y;
            
            [UIView animateWithDuration:0.3f animations:^{
                viewController.view.frame = viewFrame;
                [viewController.view layoutIfNeeded];
            }
            completion:^(BOOL finished)
            {
                
            }];
        }
    }
    else
    {
        CGRect frame = _headerView.frame;
        frame.origin.y = hide?-frame.size.height:0.0f;
        _headerView.frame = frame;
        
        for (int i = 0; i < [_viewControllers count]; i++)
        {
            UIViewController *viewController = [_viewControllers objectForKey:@(i)];
            
            CGRect viewFrame = viewController.view.frame;
            viewFrame.origin.y = frame.origin.y + frame.size.height;
            viewFrame.size.height = self.view.bounds.size.height - viewFrame.origin.y;
            
            viewController.view.frame = viewFrame;
        }
    }
}

#pragma mark -
#pragma mark Memory Warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    
}

#pragma mark -
#pragma mark AutoRotation
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    size.height = kHeaderHeight;
    [_headerView layoutSubviewsForNewViewSize:size];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_headerView layoutSubviewsForNewViewSize:CGSizeMake(self.view.frame.size.height, kHeaderHeight)];
}

@end
