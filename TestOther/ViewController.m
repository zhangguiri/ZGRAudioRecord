//
//  ViewController.m
//  TestOther
//
//  Created by 张贵日 on 2018/3/27.
//  Copyright © 2018年 zgr. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()

{
    NSTimer *_timer; // 定时器
    NSString *_filePath; // 存储路劲
}

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic , strong)AVAudioSession *session; // 录音管理
@property (nonatomic , strong) AVAudioRecorder *recorder;// 录音器
@property (nonatomic , strong) AVAudioPlayer *player; // 播放器
@property (nonatomic , strong) NSURL *recordFileUrl; // 文件地址


@end

@implementation ViewController

#pragma mark 录音前的准备
- (void) recordPrepare
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError ;
    // 设置播放和录音状态，方便录音结束时播放
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if (session == nil)
    {
        NSLog(@"Error creating session: %@",[sessionError description]);
    }
    else
    {
        [session setActive:YES error:nil];
    }
    self.session = session;
    // 设置录音相关参数
    NSMutableDictionary *recordDic = [NSMutableDictionary dictionary];
    // 采样率 8000、11025、22050、44100、96000（影响音频的质量）
    [recordDic setValue:[NSNumber numberWithInt:8000] forKey:AVSampleRateKey];
    // 音频格式有AAC,M4A,PCM等，不同的格式所产生的音频文件的大小不同；一般情况下 PCM > AAC > M4A
    [recordDic setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    // 录音通道数 1或2
    [recordDic setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    // 线性采样位数 8 、16、24、32 默认为16
    [recordDic setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    // 录音的质量
    [recordDic setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    // 获取录音文件的临时存储位置
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _filePath = [path stringByAppendingString:@"/ZGRRecor.wav"];
    self.recordFileUrl = [NSURL fileURLWithPath:_filePath];
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:_recordFileUrl settings:recordDic error:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@",    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]);

    
    /*
    unsigned int count;// 记录属性个数
    objc_property_t *properties = class_copyPropertyList([UIAlertAction class], &count);
    // 遍历
    NSMutableArray *propertiesArray = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        // objc_property_t 属性类型
        objc_property_t property = properties[i];
        // 获取属性的名称 C语言字符串
        const char *cName = property_getName(property);
        // 转换为Objective C 字符串
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        [propertiesArray addObject:name];
    }
    free(properties);
    NSLog(@"propertiesArray == %@",propertiesArray);
    
    //获取成员变量列表
    NSMutableArray *ivarArray = [NSMutableArray array];
    Ivar *ivarList = class_copyIvarList([UIAlertAction class], &count);
    for (int i = 0; i < count; i++) {
        Ivar myIvar = ivarList[i];
        const char *ivarName = ivar_getName(myIvar);
        [ivarArray addObject:[NSString stringWithUTF8String:ivarName]];
    }
    free(ivarList);
    NSLog(@"ivarArray == %@",ivarArray);
    */
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)recordAction:(id)sender {
    [self recordPrepare];

    if (_recorder) {
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        [_recorder record];
        __weak typeof (self) myself = self;
        __block NSInteger index = 0;
        _timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            myself.timeLabel.text = [NSString stringWithFormat:@"%ld",index];
            index += 1;
        }];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    else
    {
        NSLog(@"音频格式和文件存储格式不匹配，无法初始化recorder");
    }
}
- (IBAction)stopAction:(id)sender {
    
    if ([_recorder isRecording]) {
        [self.recorder stop];
        [_timer invalidate];
        _timer = nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_filePath]) {
        _timeLabel.text = [_timeLabel.text stringByAppendingString:[NSString stringWithFormat:@"文件大小为 %.2f",[[fileManager attributesOfItemAtPath:_filePath error:nil] fileSize] / 1024.0]];
    }
    
 
}
- (IBAction)playAction:(id)sender {
    
    [self.recorder stop];
    if ([self.player isPlaying]) {
        return;
    }
    
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:_recordFileUrl error:nil];
    
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.player play];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
