# Snowboy 唤醒词检测

[KITT.AI](http://kitt.ai)出品。

[Home Page](https://snowboy.kitt.ai)

[Full Documentation](http://docs.kitt.ai/snowboy) 和 [FAQ](http://docs.kitt.ai/snowboy#faq)

[Discussion Group](https://groups.google.com/a/kitt.ai/forum/#!forum/snowboy-discussion) (或者发送邮件给 snowboy-discussion@kitt.ai)

（因为我们每天都会收到很多消息，从2016年9月开始建立了讨论组。请在这里发送一般性的讨论。关于错误，请使用Github问题标签。）

版本：1.3.0（2/19/2018）

## Alexa支持

Snowboy现在为运行在Raspberry Pi上的[Alexa AVS sample app](https://github.com/alexa/alexa-avs-sample-app)提供了hands-free的体验！有关性能以及如何使用其他唤醒词模型，请参阅下面的信息。

**性能**

唤醒检测的性能通常依赖于实际的环境，例如，它是否与高质量麦克风一起使用，是否在街道上，在厨房中，是否有背景噪音等等. 所以对于性能，我们觉得最好是在使用者真实的环境中进行评估。为了方便评估，我们准备了一个可以直接安装训醒的Android应用程序：[SnowboyAlexaDemo.apk](https://github.com/Kitt-AI/snowboy/raw/master/resources/alexa/SnowboyAlexaDemo.apk) (如果您之前安装了此应用程序，请先卸载它) 。

**个人模型**

* 用以下方式创建您的个人模型：[website](https://snowboy.kitt.ai) 或者 [hotword API](https://snowboy.kitt.ai/api/v1/train/)
* 将[Alexa AVS sample app](https://github.com/alexa/alexa-avs-sample-app)（安装后）的唤醒词模型替换为您的个人模型

```
# Please replace YOUR_PERSONAL_MODEL.pmdl with the personal model you just
# created, and $ALEXA_AVS_SAMPLE_APP_PATH with the actual path where you
# cloned the Alexa AVS sample app repository.
cp YOUR_PERSONAL_MODEL.pmdl $ALEXA_AVS_SAMPLE_APP_PATH/samples/wakeWordAgent/ext/resources/alexa.umdl
```

* 在[Alexa AVS sample app code](https://github.com/alexa/alexa-avs-sample-app/blob/master/samples/wakeWordAgent/src/KittAiSnowboyWakeWordEngine.cpp)中设置 `APPLY_FRONTEND` 为 `false`，更新 `SENSITIVITY`，并重新编译

```
# Please replace $ALEXA_AVS_SAMPLE_APP_PATH with the actual path where you
# cloned the Alexa AVS sample app repository.
cd $ALEXA_AVS_SAMPLE_APP_PATH/samples/wakeWordAgent/src/

# Modify KittAiSnowboyWakeWordEngine.cpp and update SENSITIVITY at line 28.
# Modify KittAiSnowboyWakeWordEngine.cpp and set APPLY_FRONTEND to false at
# line 30.
make
```

* 运行程序，并且把唤醒词引擎设置为`kitt_ai`


**通用模型**

* 将[Alexa AVS sample app](https://github.com/alexa/alexa-avs-sample-app)（安装后）的唤醒词模型替换为您的通用模型

```
# Please replace YOUR_UNIVERSAL_MODEL.umdl with the personal model you just
# created, and $ALEXA_AVS_SAMPLE_APP_PATH with the actual path where you
# cloned the Alexa AVS sample app repository.
cp YOUR_UNIVERSAL_MODEL.umdl $ALEXA_AVS_SAMPLE_APP_PATH/samples/wakeWordAgent/ext/resources/alexa.umdl
```

* 在[Alexa AVS sample app code](https://github.com/alexa/alexa-avs-sample-app/blob/master/samples/wakeWordAgent/src/KittAiSnowboyWakeWordEngine.cpp) 中更新 `SENSITIVITY`, 并重新编译

```
# Please replace $ALEXA_AVS_SAMPLE_APP_PATH with the actual path where you
# cloned the Alexa AVS sample app repository.
cd $ALEXA_AVS_SAMPLE_APP_PATH/samples/wakeWordAgent/src/

# Modify KittAiSnowboyWakeWordEngine.cpp and update SENSITIVITY at line 28.
make
```

* 运行程序，并且把唤醒词引擎设置为`kitt_ai`


## 个人唤醒词训练服务

Snowboy现在通过 `https://snowboy.kitt.ai/api/v1/train/` 端口提供 **个人唤醒词训练服务**, 请查看[Full Documentation](http://docs.kitt.ai/snowboy)和示例[Python/Bash script](examples/REST_API)（非常欢迎贡献其他的语言)。

简单来说，`POST` 下面代码到https://snowboy.kitt.ai/api/v1/train：

        {
            "name": "a word",
            "language": "en",
            "age_group": "10_19",
            "gender": "F",
            "microphone": "mic type",
            "token": "<your auth token>",
            "voice_samples": [
                {wave: "<base64 encoded wave data>"},
                {wave: "<base64 encoded wave data>"},
                {wave: "<base64 encoded wave data>"}
            ]
        }

然后您会获得一个训练好的个人模型！


## 介绍

Snowboy是一款可定制的唤醒词检测引擎，可为您创建像 "OK Google" 或 "Alexa" 这样的唤醒词。Snowboy基于神经网络，具有以下特性：

* **高度可定制**：您可以自由定义自己的唤醒词 - 
比如说“open sesame”，“garage door open”或 “hello dreamhouse”等等。

* **总是在监听** 但保护您的个人隐私：Snowboy不使用互联网，不会将您的声音传输到云端。

* **轻量级和嵌入式的**：它可以轻松在Raspberry Pi上运行，甚至在最弱的Pi（单核700MHz ARMv6）上，Snowboy占用的CPU也少于10%。

* Apache授权!

目前Snowboy支持（查看lib文件夹）：

* 所有版本的Raspberry Pi（Raspbian基于Debian Jessie 8.0）
* 64位Mac OS X
* 64位Ubuntu 14.04
* iOS
* Android
* ARM64（aarch64，Ubuntu 16.04)

Snowboy底层库由C++写成，通过swig被封装成能在多种操作系统和语言上使用的软件库。我们欢迎新语言的封装，请随时发送你们的Pull Request！

目前我们已经现实封装的有:

* C/C++
* Java / Android
* Go（thanks to @brentnd and @deadprogram）
* Node（thanks to @evancohen和@ nekuz0r）
* Perl（thanks to @iboguslavsky）
* Python2/Python3
* iOS / Swift3（thanks to @grimlockrocks）
* iOS / Object-C（thanks to @patrickjquinn）

如果您想要支持其他硬件或操作系统，请将您的请求发送至[snowboy@kitt.ai](mailto:snowboy.kitt.ai)

注意：**Snowboy还不支持Windows** 。请在 *nix平台上编译Snowboy。

## Snowboy模型的定价

黑客：免费

* 个人使用
* 社区支持

商业：请通过[snowboy@kitt.ai](mailto:snowboy@kitt.ai)与我们联系

* 个人使用
* 商业许可证
* 技术支持

## 预训练的通用模型

为了测试方便，我们提供一些事先训练好的通用模型。当您测试那些模型时，请记住他们可能没有为您的特定设备或环境进行过优化。

以下是模型列表和您必须使用的参数：

* **resources/alexa/alexa-avs-sample-app/alexa.umdl**：这个是为[Alexa AVS sample app](https://github.com/alexa/alexa-avs-sample-app)优化过的唤醒词为“Alexa”的通用模型，将`SetSensitivity`设置为`0.6`，并将`ApplyFrontend`设置为true。当`ApplyFrontend`设置为`true`时，这是迄今为止我们公开发布的最好的“Alexa”的模型。
* **resources/models/snowboy.umdl**：唤醒词为“snowboy”的通用模型。将`SetSensitivity`设置为`0.5`，`ApplyFrontend`设置为`false`。
* **resources/models/jarvis.umdl**: 唤醒词为“Jarvis” (https://snowboy.kitt.ai/hotword/29) 的通用模型，其中包含了对应于“Jarvis”的两个唤醒词模型，所以需要设置两个`sensitivity`。将`SetSensitivity`设置为`0.8,0.8`，`ApplyFrontend`设置为`true`。
* **resources/models/smart_mirror.umdl**: 唤醒词为“Smart Mirror” (https://snowboy.kitt.ai/hotword/47) 的通用模型。将`SetSensitivity`设置为`0.5`，`ApplyFrontend`设置为`false`。
* **resources/models/subex.umdl**: 唤醒词为“Subex”(https://snowboy.kitt.ai/hotword/22014) 的通用模型。将`SetSensitivity`设置为`0.5`，`ApplyFrontend`设置为`true`。
* **resources/models/neoya.umdl**: 唤醒词为“Neo ya”(https://snowboy.kitt.ai/hotword/22171) 的通用模型。其中包含了对应于“Neo ya”的两个>唤醒词模型，所以需要设置两个`sensitivity`。将`SetSensitivity`设置为`0.7,0.7`，`ApplyFrontend`设置为`true`。
* **resources/models/hey_extreme.umdl**: 唤醒词为“Hey Extreme” (https://snowboy.kitt.ai/hotword/15428)的通用模型。将`SetSensitivity`设置为`0.6`，`ApplyFrontend`设置为`true`。
* **resources/models/computer.umdl**: 唤醒词为“Computer” (https://snowboy.kitt.ai/hotword/46) 的通用模型。将`SetSensitivity`设置为`0.6`，`ApplyFrontend`设置为`true`。
* **resources/models/view_glass.umdl**: 唤醒词为“View Glass” (https://snowboy.kitt.ai/hotword/7868) 的通用模型。将`SetSensitivity`设置为`0.7`，`ApplyFrontend`设置为`true`。

## 预编译node模块

Snowboy为一下平台编译了node模块：64位Ubuntu，MacOS X和Raspberry Pi（Raspbian 8.0+）。快速安装运行：

    npm install --save snowboy

有关示例用法，请参阅examples/Node文件夹。根据您使用的脚本，可能需要安装依赖关系库例如fs，wav或node-record-lpcm16。

## 预编译Python Demo的二进制文件
* 64 bit Ubuntu [12.04](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/ubuntu1204-x86_64-1.2.0.tar.bz2)
  / [14.04](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/ubuntu1404-x86_64-1.3.0.tar.bz2)
* [MacOS X](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/osx-x86_64-1.3.0.tar.bz2)
* Raspberry Pi with Raspbian 8.0, all versions
  ([1/2/3/Zero](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/rpi-arm-raspbian-8.0-1.3.0.tar.bz2))
* Pine64 (Debian Jessie 8.5 (3.10.102)), Nvidia Jetson TX1 and Nvidia Jetson TX2 ([download](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/pine64-debian-jessie-1.2.0.tar.bz2))
* Intel Edison (Ubilinux based on Debian Wheezy 7.8) ([download](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/edison-ubilinux-1.2.0.tar.bz2))

如果您要根据自己的环境/语言编译版本，请继续阅读。

## 依赖

要运行demo，您可能需要以下内容，具体取决于您使用的示例和您正在使用的平台：

* SoX（音频转换）
* PortAudio或PyAudio（音频录音）
* SWIG 3.0.10或以上（针对不同语言/平台编译Snowboy）
* ATLAS或OpenBLAS（矩阵计算）

在下面您还可以找到在Mac OS X，Ubuntu或Raspberry Pi上安装依赖关系所需的确切命令。

### Mac OS X

`brew` 安装 `swig`，`sox`，`portaudio` 和绑定了 `pyaudio`的Python：

    brew install swig portaudio sox
    pip install pyaudio

如果您没有安装Homebrew，请在这里[here](http://brew.sh/)下载。如果没有pip，可以在这里[here](https://pip.pypa.io/en/stable/installing/)安装。

确保您可以用麦克风录制音频：

    rec t.wav

### Ubuntu / Raspberry Pi / Pine64 / Nvidia Jetson TX1 / Nvidia Jetson TX2

首先 `apt-get` 安装 `swig`，`sox`，`portaudio`和绑定了 `pyaudio` 的 Python：

    sudo apt-get install swig3.0 python-pyaudio python3-pyaudio sox
    pip install pyaudio

然后安装 `atlas` 矩阵计算库：

    sudo apt-get install libatlas-base-dev

确保您可以用麦克风录制音频：

    rec t.wav

如果您需要额外设置您的音频（特别是Raspberry Pi），请参阅[full documentation](http://docs.kitt.ai/snowboy)。

## 编译Node插件

为Linux和Raspberry Pi编译node插件需要安装以下依赖项:

    sudo apt-get install libmagic-dev libatlas-base-dev

然后编译插件，从snowboy代码库的根目录运行以下内容：

    npm install
    ./node_modules/node-pre-gyp/bin/node-pre-gyp clean configure build

## 编译Java Wrapper

    # Make sure you have JDK installed.
    cd swig/Java
    make

SWIG将生成一个包含转换成Java封装的`java`目录和一个包含JNI库的`jniLibs`目录。

运行Java示例脚本：

    cd examples/Java
    make run

## 编译Python Wrapper

    cd swig/Python
    make

SWIG将生成一个_snowboydetect.so文件和一个简单（但难以阅读）的python 封装snowboydetect.py。我们已经提供了一个更容易读懂的python封装snowboydecoder.py。

如果不能make，请适配`swig/Python`中的Makefile到您自己的系统设置。

## 编译GO Warpper

      cd examples/Go
      go get github.com/Kitt-AI/snowboy/swig/Go
      go build -o snowboy main.go
      ./snowboy ../../resources/snowboy.umdl ../../resources/snowboy.wav

期望输出：

    Snowboy detecting keyword in ../../resources/snowboy.wav
    Snowboy detected keyword  1


更多细节，请阅读 'examples/Go/readme.md'。

## 编译Perl wrapper

    cd swig/Perl
    make

Perl示例包括使用KITT.AI RESTful API训练个人唤醒词，在检测到唤醒之后添加Google Speech API等。要运行示例，请执行以下操作

    cd examples/Perl

    # Install cpanm, if you don't already have it.
    curl -L https://cpanmin.us | perl - --sudo App::cpanminus

    # Install the dependencies. Note, on Linux you will have to install the
    # PortAudio package first, using e.g.:
    # apt-get install portaudio19-dev
    sudo cpanm --installdeps .

    # Run the unit test.
    ./snowboy_unit_test.pl

    # Run the personal model training example.
    ./snowboy_RESTful_train.pl <API_TOKEN> <Hotword> <Language>

    # Run the Snowboy Google Speech API example. By default it uses the Snowboy
    # universal hotword.
    ./snowboy_googlevoice.pl <Google_API_Key> [Hotword_Model]

## 编译iOS wrapper

在Objective-C中使用Snowboy库不需要封装. 它与Objective-C中使用C++库基本相同. 我们为iOS设备编写了一个 "fat" 静态库，请参阅这里的库`lib/ios/libsnowboy-detect.a`。

在Objective-C中初始化Snowboy检测器：

    snowboy::SnowboyDetect* snowboyDetector = new snowboy::SnowboyDetect(
        std::string([[[NSBundle mainBundle]pathForResource:@"common" ofType:@"res"] UTF8String]),
        std::string([[[NSBundle mainBundle]pathForResource:@"snowboy" ofType:@"umdl"] UTF8String]));
    snowboyDetector->SetSensitivity("0.45");        // Sensitivity for each hotword
    snowboyDetector->SetAudioGain(2.0);             // Audio gain for detection

在Objective-C中运行唤醒词检测：

    int result = snowboyDetector->RunDetection(buffer[0], bufferSize);  // buffer[0] is a float array

您可能需要按照一定的频率调用RunDetection()，从而控制CPU使用率和检测延迟。

感谢@patrickjquinn和@grimlockrocks，我们现在有了在Objective-C和Swift3中使用Snowboy的例子。看看下面的例子`examples/iOS/`和下面的截图！

<img src=https://s3-us-west-2.amazonaws.com/kittai-cdn/Snowboy/Obj-C_Demo_02172017.png alt="Obj-C Example" width=300 /> <img src=https://s3-us-west-2.amazonaws.com/kittai-cdn/Snowboy/Swift3_Demo_02172017.png alt="Swift3 Example" width=300 />

# 编译Android Wrapper

完整的README和教程在[Android README](examples/Android/README.md)，这里是一个截图：

<img src="https://s3-us-west-2.amazonaws.com/kittai-cdn/Snowboy/SnowboyAlexaDemo-Andriod.jpeg" alt="Android Alexa Demo" width=300 />

我们准备了一个可以安装并运行的Android应用程序：[SnowboyAlexaDemo.apk](https://github.com/Kitt-AI/snowboy/raw/master/resources/alexa/SnowboyAlexaDemo.apk)（如果您之前安装了此应用程序，请先卸载它们)。

## Python demo快速入门

进入 `examples/Python` 文件夹并打开你的python控制台：

    In [1]: import snowboydecoder

    In [2]: def detected_callback():
       ....:     print "hotword detected"
       ....:

    In [3]: detector = snowboydecoder.HotwordDetector("resources/snowboy.umdl", sensitivity=0.5, audio_gain=1)

    In [4]: detector.start(detected_callback)

然后对你的麦克风说"snowboy"，看看是否Snowboy检测到你。

这个 `snowboy.umdl` 文件是一个 "通用" 模型，可以检测不同的人说 "snowboy" 。 如果你想要其他的唤醒词，请去[snowboy.kitt.ai](https://snowboy.kitt.ai)录音，训练和下载你自己的个人模型(一个.pmdl文件)。

当 `sensitiviy` 设置越高，唤醒越容易触发。但是你也可能会收到更多的误唤醒。

`audio_gain` 控制是否增加（> 1）或降低（<1）输入音量。

我们提供了两个演示文件 `demo.py`, `demo2.py` 以显示更多的用法。

注意：如果您看到以下错误：

    TypeError: __init__() got an unexpected keyword argument 'model_str'

您可能正在使用旧版本的SWIG. 请升级SWIG。我们已经测试过SWIG 3.0.7和3.0.8。

## 高级用法与演示

请参阅[Full Documentation](http://docs.kitt.ai/snowboy)。

## 更改日志

**v1.3.0, 2/19/2018**

* 添加前端处理到所有平台
* 添加`resources/models/smart_mirror.umdl` 给 https://snowboy.kitt.ai/hotword/47
* 添加`resources/models/jarvis.umdl` 给 https://snowboy.kitt.ai/hotword/29
* 添加中文文档
* 清理支持的平台
* 重新定义了模型路径

**v1.2.0, 3/25/2017**

* 为[Alexa AVS sample app](https://github.com/alexa/alexa-avs-sample-app)添加更好的Alexa模型
* 新的解码器，适用于像Alexa这样的简短的词条

**v1.1.1, 3/24/2017**

* 添加Android演示
* 添加了iOS演示
* 增加了三星Artik支持
* 添加Go支持
* 增加了英特尔爱迪生支持
* 增加了Pine64的支持
* 增加了Perl支持
* 添加了更强大的“Alexa”模型（umdl）
* 通过/api/v1/train终端提供Hotword即服务。
* 解码器没有改变

**v1.1.0, 9/20/2016**

* 添加了Node的库
* 增加了对Python3的支持
* 增加了通用模型 alexa.umdl
* 更新通用模型snowboy.umdl，使其在嘈杂的环境中工作

**v1.0.4, 7/13/2016**

* 更新通用snowboy.umdl模型，使其更加健壮
* 各种改进加快检测
* Bug修复

**v1.0.3, 6/4/2016**

* 更新的通用snowboy.umdl模型，使其在非语音环境中更加强大
* 修正使用float作为输入数据时的错误
* 为Android ARMV7架构增加了库支持
* 为iOS添加了库

**v1.0.2, 5/24/2016**

* 更新通用snowboy.umdl模型
* 添加C ++示例，文档将在下一个版本中

**v1.0.1, 5/16/2016**

* VAD现在返回-2为静音，-1为错误，0为语音，大于0为触发了唤醒
* 添加了Raspberry Pi的静态库，以防人们想自己编译而不是使用二进制版本

**v1.0.0, 5/10/2016**

* 初始版本
