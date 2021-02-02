//
//  GSButtonController.h
//  Incendium Autonomae
//
//  Created by Rooshiv Arora on 1/2/21.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DJIGSViewMode) {
    DJIGSViewMode_ViewMode,
    DJIGSViewMode_EditMode,
};

@class GSButtonViewController;

@protocol GSButtonViewControllerDelegate <NSObject>

- (void)stopBtnActionInGSButtonVC:(GSButtonViewController *)GSBtnVC;
- (void)clearBtnActionInGSButtonVC:(GSButtonViewController *)GSBtnVC;
- (void)focusMapBtnActionInGSButtonVC:(GSButtonViewController *)GSBtnVC;
- (void)startBtnActionInGSButtonVC:(GSButtonViewController *)GSBtnVC;
- (void)addBtn:(UIButton *)button withActionInGSButtonVC:(GSButtonViewController *)GSBtnVC;
- (void)configBtnActionInGSButtonVC:(GSButtonViewController *)GSBtnVC;
- (void)switchToMode:(DJIGSViewMode)mode inGSButtonVC:(GSButtonViewController *)GSBtnVC;

@end

@interface GSButtonViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIButton *focusMapBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *configBtn;

@property (assign, nonatomic) DJIGSViewMode mode;
@property (weak, nonatomic) id <GSButtonViewControllerDelegate> delegate;

- (IBAction)backBtnAction:(id)sender;
- (IBAction)stopBtnAction:(id)sender;
- (IBAction)clearBtnAction:(id)sender;
- (IBAction)focusMapBtnAction:(id)sender;
- (IBAction)editBtnAction:(id)sender;
- (IBAction)startBtnAction:(id)sender;
- (IBAction)addBtnAction:(id)sender;
- (IBAction)configBtnAction:(id)sender;

@end
