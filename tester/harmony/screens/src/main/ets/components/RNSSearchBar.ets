import { Descriptor, RNComponentContext, } from '@rnoh/react-native-openharmony';
import { RNC } from "@rnoh/react-native-openharmony/generated"
import { NATIVE_BUTTON_OFFSET, NATIVE_BUTTON_VERTICAL_EDGE_MARGIN } from '../Constants'

export type RNSSearchBarDescriptor = Descriptor<"RNSSearchBar", RNC.RNSSearchBar.Props>


@Component
export struct RNSSearchBar {
  public static readonly NAME = RNC.RNSSearchBar.NAME
  public ctx!: RNComponentContext
  public isFirstScreenInStack!: boolean
  public tag: number = 0
  @State descriptor: RNSSearchBarDescriptor = {} as RNSSearchBarDescriptor
  private cleanUpCallbacks: (() => void)[] = []
  private controller: TextInputController = new TextInputController()
  private eventEmitter: RNC.RNSSearchBar.EventEmitter | undefined = undefined
  @State text: string = ''
  @State showTextInput: boolean = false;
  @State placeholder: string | undefined = undefined;
  @State backgroundColorValue: string | undefined = undefined;
  @State fontColor: string | undefined = undefined
  // @State type: InputType | undefined = undefined
  @State type: SearchType | undefined = undefined
  @State hintTextColor: string | undefined = undefined
  @State cancelIconVisiblilty: Visibility = Visibility.Visible
  @State cancelButtonText: string | undefined = undefined;
  @State headerIconColor: string | undefined = undefined
  private cleanupCommandCallback?: () => void = undefined;

  aboutToAppear() {
    this.eventEmitter = new RNC.RNSSearchBar.EventEmitter(this.ctx.rnInstance, this.tag)
    this.descriptor = this.ctx.descriptorRegistry.getDescriptor<RNSSearchBarDescriptor>(this.tag)
    this.cleanUpCallbacks.push(this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (newDescriptor) => {
        this.descriptor = (newDescriptor as RNSSearchBarDescriptor)
        this.updateState()
      }
    ))
    this.updateState()
    // TODO: event handlers, like cleanText

    this.cleanupCommandCallback = this.ctx.componentCommandReceiver.registerCommandCallback(
      this.tag,
      (command, args:ESObject[]) => {
        this.ctx.logger.info(this.tag, "ETS------------> command: " + command+',args'+args)
        if (command === 'focus') {
          this.showTextInput = true;
          setTimeout(()=>{
            this.getUIContext().getFocusController().requestFocus("search");
            // this.getUIContext().getFocusController().requestFocus("search");
          }, 100)
        } else if (command === 'blur') {
          this.getUIContext().getFocusController().clearFocus();
        } else if (command === 'unFocus') {
          this.getUIContext().getFocusController().clearFocus();
        } else if (command === 'clearText') {
          this.text = "";
        } else if (command === 'toggleCancelButton') {
            // if (JSON.stringify(args) == 'true') {
            if (args.toString() == 'true') {
              this.cancelIconVisiblilty = Visibility.Visible;
            } else {
              this.cancelIconVisiblilty = Visibility.None;
            }
        } else if (command === 'cancelSearch') {
          this.cancelSearch();
        }

      });

    let left = this.isFirstScreenInStack ? NATIVE_BUTTON_OFFSET - NATIVE_BUTTON_VERTICAL_EDGE_MARGIN :
      -NATIVE_BUTTON_VERTICAL_EDGE_MARGIN
    console.info('test zyx searchbar appear isFirstScreenInStack:'+this.isFirstScreenInStack+',tV:'+(NATIVE_BUTTON_OFFSET - NATIVE_BUTTON_VERTICAL_EDGE_MARGIN)+',fv:'+(-NATIVE_BUTTON_VERTICAL_EDGE_MARGIN))
  }

  updateState() {
    if (this.placeholder !== this.descriptor.rawProps["placeholder"]) {
      this.placeholder = this.descriptor.rawProps["placeholder"];
    }
    if (this.backgroundColorValue !== (this.descriptor.rawProps["barTintColor"] || Color.Transparent)) {
      this.backgroundColorValue = this.descriptor.rawProps["barTintColor"] || Color.Transparent
    }
    if (this.fontColor !== this.descriptor.rawProps["textColor"]) {
      this.fontColor = this.descriptor.rawProps["textColor"];
    }
    if (this.type !== this.getInputType(this.descriptor.rawProps["inputType"])) {
      this.type = this.getInputType(this.descriptor.rawProps["inputType"])
    }
    if (this.hintTextColor !== this.descriptor.rawProps["hintTextColor"] || '#333333') {
      this.hintTextColor = this.descriptor.rawProps["hintTextColor"] || '#333333';
    }
    this.cancelButtonText = this.descriptor.rawProps["cancelButtonText"] || 'cancel';
    this.headerIconColor = this.descriptor.rawProps["headerIconColor"];
    let shouldShowHintSearchIcon: boolean = this.descriptor.rawProps["shouldShowHintSearchIcon"]
  }

  aboutToDisappear() {
    this.cleanUpCallbacks.forEach(cb => cb())
  }

  getInputType(value: string): SearchType {
    switch (value) {
      case 'text':
        return SearchType.NORMAL
      case 'phone':
        return SearchType.PHONE_NUMBER
      case 'number':
        return SearchType.NUMBER
      case 'email':
        return SearchType.EMAIL
      default:
        return SearchType.NORMAL
    }
  }

  cancelSearch() {
    this.eventEmitter!.emit("cancelButtonPress", {})
    this.showTextInput = false;
    this.eventEmitter!.emit("close", {})
  }

  build() {
    Column() {
      Row() {
        if (this.showTextInput) {
          Row() {
            Search({ placeholder: this.placeholder, value: this.text })
              .layoutWeight(1)
              .fontColor(this.fontColor)
              .placeholderColor(this.hintTextColor)
              .searchIcon({ color: this.headerIconColor })
              .backgroundColor(this.backgroundColorValue)
              .cancelButton({ style: CancelButtonStyle.CONSTANT})
              .type(this.type)
              .focusable(true)
              .onChange((value: string) => {
              this.text = value
              this.eventEmitter!.emit("changeText", { text: value })
            })
            .onFocus(() => {
              this.eventEmitter!.emit("searchFocus", {})
            })
            .onBlur(() => {
              this.eventEmitter!.emit("searchBlur", {})
            })
            .onSubmit(() => {
              this.eventEmitter?.emit("searchButtonPress", {
                text: this.text
                })
              })
            .id("search")
            Text(this.cancelButtonText)
              .padding({ left: 5 })
              // .fontColor(this.getCancelButtonColor())
              .visibility(this.cancelIconVisiblilty)
              .onClick((e) => {
                if (this.text !== "") {
                  this.text = "";
                  this.eventEmitter!.emit("changeText", { text: this.text })
                }
                this.cancelSearch()
              })
          }.width(200)
        } else {
          SymbolGlyph($r('sys.symbol.magnifyingglass')).fontSize(26).onClick(() => {
            this.showTextInput = true;
            this.eventEmitter!.emit("open", {})
          })
        }
      }
    }
    .width("100%")
    .height("100%")
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.End)
    .offset({
      left: this.isFirstScreenInStack ? NATIVE_BUTTON_OFFSET - NATIVE_BUTTON_VERTICAL_EDGE_MARGIN :
        -NATIVE_BUTTON_VERTICAL_EDGE_MARGIN,
    })
  }
}
