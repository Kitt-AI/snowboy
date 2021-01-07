*Dear KITT.AI users,*

*We are writing this update to let you know that we plan to shut down all KITT.AI products (Snowboy, NLU and Chatflow) by Dec. 31st, 2020.*

*we launched our first product Snowboy in 2016, and then NLU and Chatflow later that year. Since then, we have served more than 85,000 developers, worldwide, accross all our products. It has been 4 extraordinary years in our life, and we appreciate the opportunity to be able to serve the community.*

*The field of artificial intelligence is moving rapidly. As much as we like our products, we still see that they are getting outdated and are becoming difficult to maintain. All official websites/APIs for our products will be taken down by Dec. 31st, 2020. Our github repositories will remain open, but only community support will be available from this point beyond.*

*Thank you all, and goodbye!*

*The KITT.AI Team  
Mar. 18th, 2020*

# Snowboy Hotword Detection

by [KITT.AI](http://kitt.ai).

[Home Page](https://snowboy.kitt.ai)

[Full Documentation](http://docs.kitt.ai/snowboy) and [FAQ](http://docs.kitt.ai/snowboy#faq)

[Discussion Group](https://groups.google.com/a/kitt.ai/forum/#!forum/snowboy-discussion) (or send email to snowboy-discussion@kitt.ai)

[Commercial application FAQ](README_commercial.md)

Version: 1.3.0 (2/19/2018)

## Alexa support

Snowboy now brings hands-free experience to the [Alexa AVS sample app](https://github.com/alexa/avs-device-sdk/wiki/Raspberry-Pi-Quick-Start-Guide-with-Script) on Raspberry Pi! See more info below regarding the performance and how you can use other hotword models. The following instructions currently support AVS sdk Version 1.12.1.

**Performance**

The performance of hotword detection usually depends on the actual environment, e.g., is it used with a quality microphone, is it used on the street, in a kitchen, or is there any background noise, etc. So we feel it is best for the users to evaluate it in their real environment. For the evaluation purpose, we have prepared an Android app which can be installed and run out of box: [SnowboyAlexaDemo.apk](https://github.com/Kitt-AI/snowboy/raw/master/resources/alexa/SnowboyAlexaDemo.apk) (please uninstall any previous versions first if you have installed this app before). 

**Kittai KWD Engine**

* Set up [Alexa AVS sample app](https://github.com/alexa/avs-device-sdk/wiki/Raspberry-Pi-Quick-Start-Guide-with-Script) following the official AVS instructions

* Apply patch to replace the Sensory KWD engine with Kittai engine
```
# Copy the patch file to the root directory of Alexa AVS sample app. Please replace $ALEXA_AVS_SAMPLE_APP_PATH with the actual path where you
# cloned the Alexa AVS sample app repository, and replace $SNOWBOY_ROOT_PATH with the actual path where you clone the Snowboy repository
cd $ALEXA_AVS_SAMPLE_APP_PATH
cp $SNOWBOY_PATH/resource/alexa/alexa-avs-sample-app/avs-kittai.patch ./

# Apply the patch, this will modify the scripts setup.sh and pi.sh
patch < avs-kittai.patch
```

* Re-compile the avs-device-sdk and sample app
```
sudo bash setup.sh config.json
```

* Run the sample app
```
sudo bash startsample.sh
```

Here is a [demo video](https://www.youtube.com/watch?v=wiLEr6TeE58) for how to use Snowboy hotword engine in Alexa Voice Service.

**Personal model**

* Create your personal hotword model through our [website](https://snowboy.kitt.ai) or [hotword API](https://snowboy.kitt.ai/api/v1/train/)


* Put your personal model in [snowboy/resources](https://github.com/Kitt-AI/snowboy/tree/master/resources)
```
# Please put YOUR_PERSONAL_MODEL.pmdl in $ALEXA_AVS_SAMPLE_APP_PATH/third-party/snowboy/resources,
# and $ALEXA_AVS_SAMPLE_APP_PATH with the actual path where you put the Alexa AVS sample app repository.

cp YOUR_PERSONAL_MODEL.pmdl $ALEXA_AVS_SAMPLE_APP_PATH/third-party/snowboy/resources/

```

* Replace the model name 'alexa.umdl' with your personal model name, update `KITT_AI_SENSITIVITY`, set `KITT_AI_APPLY_FRONT_END_PROCESSING` to `false` in the [Alexa AVS sample app code](https://github.com/alexa/avs-device-sdk/blob/master/KWD/KWDProvider/src/KeywordDetectorProvider.cpp) and re-compile
```
# Modify $ALEXA_AVS_SAMPLE_APP_PATH/avs-device-sdk/blob/master/KWD/KWDProvider/src/KeywordDetectorProvider.cpp:
#     Replace the model name 'alexa.umdl' with your personal model name 'YOUR_PERSONAL_MODEL.pmdl' at line 52
#     Update `KITT_AI_SENSITIVITY` at line 26
#     Set `KITT_AI_APPLY_FRONT_END_PROCESSING` to `false` at line 32
sudo bash setup.sh config.json
```

* Run the wake word agent with engine set to `kitt_ai`!

Here is a [demo video](https://www.youtube.com/watch?v=9Bj8kdfwG7I) for how to use a personal model in Alexa Voice Service.

**Universal model**

* Put your personal model in [snowboy/resources](https://github.com/Kitt-AI/snowboy/tree/master/resources)
```
# Please put YOUR_UNIVERSAL_MODEL.umdl in $ALEXA_AVS_SAMPLE_APP_PATH/third-party/snowboy/resources,
# and $ALEXA_AVS_SAMPLE_APP_PATH with the actual path where you put the Alexa AVS sample app repository.

cp YOUR_UNIVERSAL_MODEL.umdl $ALEXA_AVS_SAMPLE_APP_PATH/third-party/snowboy/resources/

```

* Replace the model name 'alexa.umdl' with your universal model name, update `KITT_AI_SENSITIVITY` in the [Alexa AVS sample app code](https://github.com/alexa/avs-device-sdk/blob/master/KWD/KWDProvider/src/KeywordDetectorProvider.cpp) and re-compile
```
# Modify $ALEXA_AVS_SAMPLE_APP_PATH/avs-device-sdk/blob/master/KWD/KWDProvider/src/KeywordDetectorProvider.cpp:
#     Replace the model name 'alexa.umdl' with your universal model name 'YOUR_UNIVERSAL_MODEL.umdl' at line 52
#     Update `KITT_AI_SENSITIVITY` at line 26
sudo bash setup.sh config.json
```

* Run the wake word agent with engine set to `kitt_ai`!


## Hotword as a Service

Snowboy now offers **Hotword as a Service** through the ``https://snowboy.kitt.ai/api/v1/train/``
endpoint. Check out the [Full Documentation](http://docs.kitt.ai/snowboy) and example [Python/Bash script](examples/REST_API) (other language contributions are very welcome).

As a quick start, ``POST`` to https://snowboy.kitt.ai/api/v1/train:

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

then you'll get a trained personal model in return!

## Introduction

Snowboy is a customizable hotword detection engine for you to create your own
hotword like "OK Google" or "Alexa". It is powered by deep neural networks and
has the following properties:

* **highly customizable**: you can freely define your own magic phrase here –
let it be “open sesame”, “garage door open”, or “hello dreamhouse”, you name it.

* **always listening** but protects your privacy: Snowboy does not use Internet
and does *not* stream your voice to the cloud.

* light-weight and **embedded**: it even runs on a Raspberry Pi and consumes
less than 10% CPU on the weakest Pi (single-core 700MHz ARMv6).

* Apache licensed!

Currently Snowboy supports (look into the [lib](lib) folder):

* all versions of Raspberry Pi (with Raspbian based on Debian Jessie 8.0)
* 64bit Mac OS X
* 64bit Ubuntu 14.04
* iOS
* Android
* ARM64 (aarch64, Ubuntu 16.04)

It ships in the form of a **C++ library** with language-dependent wrappers
generated by SWIG. We welcome wrappers for new languages -- feel free to send a
pull request!

Currently we have built wrappers for:

* C/C++
* Java/Android
* Go (thanks to @brentnd and @deadprogram)
* Node (thanks to @evancohen and @nekuz0r)
* Perl (thanks to @iboguslavsky)
* Python2/Python3
* iOS/Swift3 (thanks to @grimlockrocks)
* iOS/Object-C (thanks to @patrickjquinn)

If you want support on other hardware/OS, please send your request to
[snowboy@kitt.ai](mailto:snowboy.kitt.ai)

Note: **Snowboy does not support Windows** yet. Please build Snowboy on *nix platforms.

## Pricing for Snowboy models

Hackers: free

* Personal use
* Community support

Business: please contact us at [snowboy@kitt.ai](mailto:snowboy@kitt.ai)

* Personal use
* Commercial license
* Technical support

## Pretrained universal models

We provide pretrained universal models for testing purpose. When you test those
models, bear in mind that they may not be optimized for your specific device or
environment.

Here is the list of the models, and the parameters that you have to use for them:

* **resources/alexa/alexa-avs-sample-app/alexa.umdl**: Universal model for the hotword "Alexa" optimized for [Alexa AVS sample app](https://github.com/alexa/alexa-avs-sample-app). Set SetSensitivity to 0.6, and set ApplyFrontend to true. This is so far the best "Alexa" model we released publicly, when ApplyFrontend is set to true.
* **resources/models/snowboy.umdl**: Universal model for the hotword "Snowboy". Set SetSensitivity to 0.5 and ApplyFrontend to false.
* **resources/models/jarvis.umdl**: Universal model for the hotword "Jarvis" (https://snowboy.kitt.ai/hotword/29). It has two different models for the hotword Jarvis, so you have to use two sensitivites. Set sensitivities to "0.8,0.80" and ApplyFrontend to true.
* **resources/models/smart_mirror.umdl**: Universal model for the hotword "Smart Mirror" (https://snowboy.kitt.ai/hotword/47). Set sensitivity to Sensitivity to 0.5, and ApplyFrontend to false.
* **resources/models/subex.umdl**: Universal model for the hotword "Subex" (https://snowboy.kitt.ai/hotword/22014). Set sensitivity to Sensitivity to 0.5, and ApplyFrontend to true.
* **resources/models/neoya.umdl**: Universal model for the hotword "Neo ya" (https://snowboy.kitt.ai/hotword/22171). It has two different models for the hotword "Neo ya", so you have to use two sensitivites. Set sensitivities to "0.7,0.7", and ApplyFrontend to true.
* **resources/models/hey_extreme.umdl**: Universal model for the hotword "Hey Extreme" (https://snowboy.kitt.ai/hotword/15428). Set sensitivity to Sensitivity to 0.6, and ApplyFrontend to true.
* **resources/models/computer.umdl**: Universal model for the hotword "Computer" (https://snowboy.kitt.ai/hotword/46). Set sensitivity to Sensitivity to 0.6, and ApplyFrontend to true.
* **resources/models/view_glass.umdl**: Universal model for the hotword "View Glass" (https://snowboy.kitt.ai/hotword/7868). Set Sensitivity to 0.7, and ApplyFrontend to true.

## Precompiled node module

Snowboy is available in the form of a native node module precompiled for:
64 bit Ubuntu, MacOS X, and the Raspberry Pi (Raspbian 8.0+). For quick
installation run:

    npm install --save snowboy

For sample usage see the `examples/Node` folder. You may have to install
dependencies like `fs`, `wav` or `node-record-lpcm16` depending on which script
you use.

## Precompiled Binaries with Python Demo
* 64 bit Ubuntu [14.04](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/ubuntu1404-x86_64-1.3.0.tar.bz2)
* [MacOS X](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/osx-x86_64-1.3.0.tar.bz2)
* Raspberry Pi with Raspbian 8.0, all versions
  ([1/2/3/Zero](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/rpi-arm-raspbian-8.0-1.3.0.tar.bz2))
  
If you want to compile a version against your own environment/language, read on.

## Dependencies

To run the demo you will likely need the following, depending on which demo you
use and what platform you are working with:

* SoX (audio conversion)
* PortAudio or PyAudio (audio capturing)
* SWIG 3.0.10 or above (compiling Snowboy for different languages/platforms)
* ATLAS or OpenBLAS (matrix computation)

You can also find the exact commands you need to install the dependencies on
Mac OS X, Ubuntu or Raspberry Pi below.

### Mac OS X

`brew` install `swig`, `sox`, `portaudio` and its Python binding `pyaudio`:

    brew install swig portaudio sox
    pip install pyaudio

If you don't have Homebrew installed, please download it [here](http://brew.sh/). If you don't have `pip`, you can install it [here](https://pip.pypa.io/en/stable/installing/).

Make sure that you can record audio with your microphone:

    rec t.wav

### Ubuntu/Raspberry Pi/Pine64/Nvidia Jetson TX1/Nvidia Jetson TX2

First `apt-get` install `sox`, `portaudio` and its Python binding `pyaudio`:

    sudo apt-get install python-pyaudio python3-pyaudio sox
    pip install pyaudio
    
Compile a supported swig version (3.0.10 or above)

    wget http://downloads.sourceforge.net/swig/swig-3.0.10.tar.gz
    sudo apt-get install libpcre3 libpcre3-dev
    ./configure --prefix=/usr                  \
            --without-clisp                    \
            --without-maximum-compile-warnings &&
    make
    make install &&
    install -v -m755 -d /usr/share/doc/swig-3.0.10 &&
    cp -v -R Doc/* /usr/share/doc/swig-3.0.10
    
Then install the `atlas` matrix computing library:

    sudo apt-get install libatlas-base-dev
    
Make sure that you can record audio with your microphone:

    rec t.wav
        
If you need extra setup on your audio (especially on a Raspberry Pi), please see the [full documentation](http://docs.kitt.ai/snowboy).

## Compile a Node addon
Compiling a node addon for Linux and the Raspberry Pi requires the installation of the following dependencies:

    sudo apt-get install libmagic-dev libatlas-base-dev

Then to compile the addon run the following from the root of the snowboy repository:

    npm install
    ./node_modules/node-pre-gyp/bin/node-pre-gyp clean configure build

## Compile a Java Wrapper

    # Make sure you have JDK installed.
    cd swig/Java
    make

SWIG will generate a directory called `java` which contains converted Java wrappers and a directory called `jniLibs` which contains the JNI library.

To run the Java example script:

    cd examples/Java
    make run

## Compile a Python Wrapper

    cd swig/Python
    make

SWIG will generate a `_snowboydetect.so` file and a simple (but hard-to-read) python wrapper `snowboydetect.py`. We have provided a higher level python wrapper `snowboydecoder.py` on top of that.
    
Feel free to adapt the `Makefile` in `swig/Python` to your own system's setting if you cannot `make` it.

## Compile a GO Wrapper

	cd examples/Go
	go get github.com/Kitt-AI/snowboy/swig/Go
	go build -o snowboy main.go
	./snowboy ../../resources/snowboy.umdl ../../resources/snowboy.wav
	
Expected Output:

```
Snowboy detecting keyword in ../../resources/snowboy.wav
Snowboy detected keyword  1
```

For more, please read `examples/Go/readme.md`.

## Compile a Perl Wrapper

    cd swig/Perl
    make

The Perl examples include training personal hotword using the KITT.AI RESTful APIs, adding Google Speech API after the hotword detection, etc. To run the examples, do the following

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


## Compile an iOS Wrapper

Using Snowboy library in Objective-C does not really require a wrapper. It is basically the same as using C++ library in Objective-C. We have compiled a "fat" static library for iOS devices, see the library here `lib/ios/libsnowboy-detect.a`.

To initialize Snowboy detector in Objective-C:

    snowboy::SnowboyDetect* snowboyDetector = new snowboy::SnowboyDetect(
        std::string([[[NSBundle mainBundle]pathForResource:@"common" ofType:@"res"] UTF8String]),
        std::string([[[NSBundle mainBundle]pathForResource:@"snowboy" ofType:@"umdl"] UTF8String]));
    snowboyDetector->SetSensitivity("0.45");        // Sensitivity for each hotword
    snowboyDetector->SetAudioGain(2.0);             // Audio gain for detection

To run hotword detection in Objective-C:

    int result = snowboyDetector->RunDetection(buffer[0], bufferSize);  // buffer[0] is a float array

You may want to play with the frequency of the calls to `RunDetection()`, which controls the CPU usage and the detection latency.

Thanks to @patrickjquinn and @grimlockrocks, we now have examples of using Snowboy in both Objective-C and Swift3. Check out the examples at `examples/iOS/`, and the screenshots below!

<img src=https://s3-us-west-2.amazonaws.com/kittai-cdn/Snowboy/Obj-C_Demo_02172017.png alt="Obj-C Example" width=300 /> <img src=https://s3-us-west-2.amazonaws.com/kittai-cdn/Snowboy/Swift3_Demo_02172017.png alt="Swift3 Example" width=300 />


## Compile an Android Wrapper

Full README and tutorial is in [Android README](examples/Android/README.md) and here's a screenshot:

<img src="https://s3-us-west-2.amazonaws.com/kittai-cdn/Snowboy/SnowboyAlexaDemo-Andriod.jpeg" alt="Android Alexa Demo" width=300 />

We have prepared an Android app which can be installed and run out of box: [SnowboyAlexaDemo.apk](https://github.com/Kitt-AI/snowboy/raw/master/resources/alexa/SnowboyAlexaDemo.apk) (please uninstall any previous one first if you installed this app before).

## Quick Start for Python Demo

Go to the `examples/Python` folder and open your python console:

    In [1]: import snowboydecoder
    
    In [2]: def detected_callback():
       ....:     print "hotword detected"
       ....:
    
    In [3]: detector = snowboydecoder.HotwordDetector("resources/snowboy.umdl", sensitivity=0.5, audio_gain=1)
    
    In [4]: detector.start(detected_callback)
    
Then speak "snowboy" to your microphone to see whetheer Snowboy detects you.

The `snowboy.umdl` file is a "universal" model that detect different people speaking "snowboy". If you want other hotwords, please go to [snowboy.kitt.ai](https://snowboy.kitt.ai) to record, train and downloand your own personal model (a `.pmdl` file).

When `sensitiviy` is higher, the hotword gets more easily triggered. But you might get more false alarms.

`audio_gain` controls whether to increase (>1) or decrease (<1) input volume.

Two demo files `demo.py` and `demo2.py` are provided to show more usages.

Note: if you see the following error:

    TypeError: __init__() got an unexpected keyword argument 'model_str'
    
You are probably using an old version of SWIG. Please upgrade. We have tested with SWIG version 3.0.7 and 3.0.8.

## Advanced Usages & Demos

See [Full Documentation](http://docs.kitt.ai/snowboy).

## Change Log

**v1.3.0, 2/19/2018**

* Added Frontend processing for all platforms
* Added `resources/models/smart_mirror.umdl` for https://snowboy.kitt.ai/hotword/47
* Added `resources/models/jarvis.umdl` for https://snowboy.kitt.ai/hotword/29
* Added README for Chinese
* Cleaned up the supported platforms
* Re-structured the model path

**v1.2.0, 3/25/2017**

* Added better Alexa model for [Alexa AVS sample app](https://github.com/alexa/alexa-avs-sample-app)
* New decoder that works well for short hotwords like Alexa

**v1.1.1, 3/24/2017**

* Added Android demo
* Added iOS demos
* Added Samsung Artik support
* Added Go support
* Added Intel Edison support
* Added Pine64 support
* Added Perl Support
* Added a more robust "Alexa" model (umdl)
* Offering Hotword as a Service through ``/api/v1/train`` endpoint.
* Decoder is not changed.

**v1.1.0, 9/20/2016**

* Added library for Node.
* Added support for Python3.
* Added universal model `alexa.umdl`
* Updated universal model `snowboy.umdl` so that it works in noisy environment.

**v1.0.4, 7/13/2016**

* Updated universal `snowboy.umdl` model to make it more robust.
* Various improvements to speed up the detection.
* Bug fixes.

**v1.0.3, 6/4/2016**

* Updated universal `snowboy.umdl` model to make it more robust in non-speech environment.
* Fixed bug when using float as input data.
* Added library support for Android ARMV7 architecture.
* Added library for iOS.

**v1.0.2, 5/24/2016**

* Updated universal `snowboy.umdl` model
* added C++ examples, docs will come in next release.

**v1.0.1, 5/16/2016**

* VAD now returns -2 on silence, -1 on error, 0 on voice and >0 on triggered models
* added static library for Raspberry Pi in case people want to compile themselves instead of using the binary version

**v1.0.0, 5/10/2016**

* initial release
