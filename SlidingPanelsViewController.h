//
//  SlidingPanelsViewController.h
//
//  Created by Suraj Thomas K on 3/30/15.
//  2015 No Heaven Promised
//

#import <UIKit/UIKit.h>

@protocol SlidingPanelsViewDelegate <NSObject>

/**
 *  Callback when a new view controller is selected and is displayed
 *
 *  @param viewController The view controller that is selected
 *  @param index          Index of the view controller
 */
- (void)didSelectViewController:(UIViewController *)viewController atIndex:(int)index;

@end

@interface SlidingPanelsViewController : UIViewController

/**
 *  Delegate object, which will be invoked on selecting a new view controller
 */
@property (nonatomic, weak) id<SlidingPanelsViewDelegate> delegate;
/**
 *  Index of current selected view controller index
 */
@property (nonatomic, readonly) int selectedViewIndex;
/**
 *  A dictionary of all view controllers. The key will be index as NSNumber object
 */
@property (nonatomic, readonly) NSDictionary *viewControllers;
/**
 *  Instance of current selected view controller
 */
@property (nonatomic, readonly) UIViewController *currentViewController;
/**
 *  Instance of next view controller
 */
@property (nonatomic, readonly) UIViewController *nextViewController;
/**
 *  Instance of previous view controller
 */
@property (nonatomic, readonly) UIViewController *previousViewController;
/**
 *  UIImageView, that acts as the background of header view
 */
@property (nonatomic, readonly) UIImageView *headerBackground;

/**
 *  Method to add a new view controller at the right most end
 *
 *  @param viewController Instance of view controller to be added
 */
- (void)addViewController:(UIViewController *)viewController;
/**
 *  Method to insert a view controller at a particular index. All the view controllers with higher indices will be moved to right
 *
 *  @param viewController Instance of view controller to be inserted
 *  @param index          Index at which to insert the view controller
 */
- (void)insertViewController:(UIViewController *)viewController atIndex:(int)index;
/**
 *  Method to remove a view controller. All the view controllers to the right will be moved left
 *
 *  @param viewController Instance of the view controller to be removed
 */
- (void)removeViewController:(UIViewController *)viewController;
/**
 *  Method to remove a view controller at an index. All the view controllers with higher indices will be moved left
 *
 *  @param index Index of the view controller to be removed
 */
- (void)removeViewControllerAtIndex:(int)index;
/**
 *  Method to hide/show header view
 *
 *  @param hide     hide/show
 *  @param animated animated or not
 */
- (void)hideHeaderView:(BOOL)hide animated:(BOOL)animated;
/**
 *  Method to select view controller at index
 *
 *  @param index Index of the view controller to be selected
 */
- (void)selectViewControllerAtIndex:(int)index;
/**
 *  Method to select a view controller
 *
 *  @param viewController view controller to be selected
 */
- (void)selectViewController:(UIViewController *)viewController;
@end
