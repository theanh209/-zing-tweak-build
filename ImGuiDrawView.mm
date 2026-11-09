#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
//Imgui library
#import "Esp/CaptainHook.h"
#import "Esp/ImGuiDrawView.h"
#import "IMGUI/imgui.h"
#import "IMGUI/imgui_impl_metal.h"
#import "IMGUI/Honkai.h"
//Patch library (Mày giữ nguyên mấy cái include này, vì nó chứa hàm vm, vm_unity, Dobby...)
#import "5Toubun/NakanoIchika.h"
#import "5Toubun/NakanoNino.h"
#import "5Toubun/NakanoMiku.h"
#import "5Toubun/NakanoYotsuba.h"
#import "5Toubun/NakanoItsuki.h"
#import "5Toubun/dobby.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale [UIScreen mainScreen].scale

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@end

@implementation ImGuiDrawView

// Hàm hook mẫu (giữ nguyên)
void (*huy)(void *instance);
void _huy(void *instance)
{
    huy(instance);
}

static bool MenDeal = true;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];

    if (!self.device) abort();
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    ImGui::StyleColorsClassic(); 
    ImFont* font = io.Fonts->AddFontFromMemoryCompressedTTF((void*)Honkai_compressed_data, Honkai_compressed_size, 45.0f, NULL, io.Fonts->GetGlyphRangesVietnamese()); // Sửa thành tiếng Việt
    ImGui_ImplMetal_Init(_device);
    return self;
}

+ (void)showChange:(BOOL)open
{
    MenDeal = open;
}

- (MTKView *)mtkView
{
    return (MTKView *)self.view;
}

- (void)loadView
{
    CGFloat w = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width;
    CGFloat h = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height;
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;
}

#pragma mark - Interaction
- (void)updateIOWithTouchEvent:(UIEvent *)event
{
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches)
    {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled)
        {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(MTKView*)view
{
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;

    CGFloat framebufferScale = view.window.screen.scale ?: UIScreen.mainScreen.scale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 120);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    // BIẾN CHO CÁC NÚT BẤM (THEO MENU LỘC LỎ)
    static bool teleportAuto = false;
    static bool miniBoot = false;
    static bool voHanNitro = false;
    static bool ecu3Luot = false;
    static bool giaToc = false;
    static bool teleportButton = false;
    static bool thoatNhanh = false;
    static bool nitroNhanh = false;
    static bool tuDuaXe = false;
    static bool autoDuaLapTrinh = false;
    static bool kySinh = false;
    static bool fakeTen = false;
    
    // Biến trạng thái active
    static bool teleportAuto_active = false;
    static bool miniBoot_active = false;
    static bool voHanNitro_active = false;
    static bool giaToc_active = false;

    [self.view setUserInteractionEnabled:(MenDeal ? YES : NO)];

    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"ImGui Zing"];

        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        
        ImFont* font = ImGui::GetFont();
        font->Scale = 15.f / font->FontSize;
        
        CGFloat x = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width) - 400) / 2;
        CGFloat y = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height) - 450) / 2;
        
        ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);
        ImGui::SetNextWindowSize(ImVec2(400, 450), ImGuiCond_FirstUseEver); 
        
        if (MenDeal == true)
        {     
            // ĐỔI TÊN MENU
            ImGui::Begin("Zing Speed Mobile - Lộc Lỏ", &MenDeal);
            
            if (ImGui::BeginTabBar("MainTabBar"))  
            {
                if (ImGui::BeginTabItem("Function"))
                {
                    ImGui::TextColored(ImVec4(1.0f, 0.8f, 0.0f, 1.0f), "admin sẽ bổ sung map thiếu khi bạn báo cáo");
                    ImGui::TextColored(ImVec4(1.0f, 0.8f, 0.0f, 1.0f), "Dua kín để bảo vệ acc của bạn");
                    ImGui::Separator();

                    ImGui::Columns(2, "hack_cols", false);

                    // Cột 1
                    ImGui::Checkbox("Teleport Auto", &teleportAuto);
                    ImGui::Checkbox("Mini Boot", &miniBoot);
                    ImGui::Checkbox("Vô Hạn Nitro", &voHanNitro);
                    ImGui::Checkbox("ECU 3 Lượt", &ecu3Luot);
                    ImGui::Checkbox("Giả Tốc", &giaToc);

                    ImGui::NextColumn();

                    // Cột 2
                    ImGui::Checkbox("Teleport Button", &teleportButton);
                    ImGui::Checkbox("Thoát Nhanh", &thoatNhanh);
                    ImGui::Checkbox("Nitro Nhanh", &nitroNhanh);
                    ImGui::Checkbox("Tự Đua Xe", &tuDuaXe);

                    ImGui::Columns(1);

                    ImGui::Separator();

                    ImGui::Checkbox("1. Theo đường hướng dẫn", &autoDuaLapTrinh); 
                    ImGui::Checkbox("2. Tự ra giữa đường", &autoDuaLapTrinh);
                    ImGui::Checkbox("Auto Đua Lập Trình", &autoDuaLapTrinh);

                    ImGui::TextColored(ImVec4(0.0f, 1.0f, 0.0f, 1.0f), "Trạng thái: Đang tự động đua theo lập trình!");
                    ImGui::Text("Map ID: 157 (Hồ Long Tinh)");
                    ImGui::Text("Danh sách các map đang thiếu data");

                    ImGui::Separator();

                    ImGui::Checkbox("Ký Sinh", &kySinh);
                    ImGui::SameLine();
                    ImGui::Checkbox("Fake Tên", &fakeTen);

                    ImGui::EndTabItem();  
                }

                if (ImGui::BeginTabItem("More"))
                {
                    ImGui::Text("Các chức năng khác...");
                    ImGui::EndTabItem();  
                }

                ImGui::EndTabBar();  
            }

            ImGui::End();   
        }
        
        ImDrawList* draw_list = ImGui::GetBackgroundDrawList();

        // ========== NÚT TRÒN TELEPORT (HIỆN KHI TÍCH CHECKBOX) ==========
        if (teleportButton) { 
            ImGui::SetNextWindowPos(ImVec2(io.DisplaySize.x - 100, io.DisplaySize.y / 2), ImGuiCond_Always);
            ImGui::SetNextWindowSize(ImVec2(60, 60), ImGuiCond_Always);
            ImGui::Begin("TeleBtn", NULL, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoBackground | ImGuiWindowFlags_NoCollapse);
            
            ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.8f, 0.1f, 0.1f, 0.8f));
            ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(1.0f, 0.2f, 0.2f, 1.0f));
            ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.5f, 0.0f, 0.0f, 1.0f));
            ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 30.0f); 
            
            if (ImGui::Button("Tele", ImVec2(50, 50))) {
                // CODE TELEPORT
                // vm_unity(ENCRYPTOFFSET("0x..."), strtoul(ENCRYPTHEX("0x..."), nullptr, 0));
            }
            ImGui::PopStyleVar();
            ImGui::PopStyleColor(3);
            ImGui::End(); 
        }

// ========== CODE CHỨC NĂNG (MÀY TỰ NHÉT OFFSET VÀO) ==========
        if(teleportAuto){
            if(teleportAuto_active == NO){
                // vm_unity(ENCRYPTOFFSET("OFFSET_TELEPORT"), strtoul(ENCRYPTHEX("HEX_BAT"), nullptr, 0));
            }
            teleportAuto_active = YES;
        } else {
            if(teleportAuto_active == YES){
                // vm_unity(ENCRYPTOFFSET("OFFSET_TELEPORT"), strtoul(ENCRYPTHEX("HEX_TAT"), nullptr, 0));
            }
            teleportAuto_active = NO;
        }

        if(miniBoot){
            if(miniBoot_active == NO){
                // vm_unity(ENCRYPTOFFSET("OFFSET_MINIBOOT"), strtoul(ENCRYPTHEX("HEX_BAT"), nullptr, 0));
            }
            miniBoot_active = YES;
        } else {
            if(miniBoot_active == YES){
                // vm_unity(ENCRYPTOFFSET("OFFSET_MINIBOOT"), strtoul(ENCRYPTHEX("HEX_TAT"), nullptr, 0));
            }
            miniBoot_active = NO;
        }

        if(voHanNitro){
            if(voHanNitro_active == NO){
                // vm_unity(ENCRYPTOFFSET("OFFSET_NITRO"), strtoul(ENCRYPTHEX("HEX_BAT"), nullptr, 0));
            }
            voHanNitro_active = YES;
        } else {
            if(voHanNitro_active == YES){
                // vm_unity(ENCRYPTOFFSET("OFFSET_NITRO"), strtoul(ENCRYPTHEX("HEX_TAT"), nullptr, 0));
            }
            voHanNitro_active = NO;
        }
// ========== KẾT THÚC CODE CHỨC NĂNG ==========

        ImGui::Render();
        ImDrawData* draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
      
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];

        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size
{
}

@end