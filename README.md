# Snowboy Hotword Detection

by [KITT.AI](http://kitt.ai).

[Home Page](https://snowboy.kitt.ai)

[Full Documentation](http://docs.kitt.ai/snowboy) and [FAQ](http://docs.kitt.ai/snowboy#faq)

[Discussion Group](https://groups.google.com/a/kitt.ai/forum/#!forum/snowboy-discussion) (or send email to snowboy-discussion@kitt.ai)

(The discussion group is new since September 2016 as we are getting many messages every day. Please send general questions there. For bugs, use Github issues.)

Version: 1.2.0 (3/25/2017)

## Alexa support

Snowboy now brings hands-free experience to the [Alexa AVS sample app](https://github.com/alexa/alexa-avs-sample-app) on Raspberry Pi! See more info below regarding the performance and how you can use other hotword models.

**Performance**
The performance of hotword detection usually depends on the actually environment, e.g., is it used with a quality microphone, is it used on the street, in a kitchen, or is there any background noise, etc. So we feel it is best for the users to evaluate it in their real environment. For the evaluation purpose, we have prepared an Android app which can be installed and run out of box. The app is here:

* **resources/alexa/SnowboyAlexaDemo.apk**

**Personal model**
* Create your personal hotword model through our [website](https://snowboy.kitt.ai) or [hotword API](https://snowboy.kitt.ai/api/v1/train/)
* Replace the hotword model in [Alexa AVS sample app](https://github.com/alexa/alexa-avs-sample-app) (after installation) with your personal model

```
# Please replace YOUR_PERSONAL_MODEL.pmdl with the personal model you just
# created, and $ALEXA_AVS_SAMPLE_APP_PATH with the actual path where you
# cloned the Alexa AVS sample app repository.
cp YOUR_PERSONAL_MODEL.pmdl $ALEXA_AVS_SAMPLE_APP_PATH/samples/wakeWordAgent/ext/resources/alexa.umdl
```

* Set `APPLY_FRONTEND` to `false` and update `SENSITIVITY` in the [Alexa AVS sample app code](https://github.com/alexa/alexa-avs-sample-app/blob/master/samples/wakeWordAgent/src/KittAiSnowboyWakeWordEngine.cpp) and re-compile

```
# Please replace $ALEXA_AVS_SAMPLE_APP_PATH with the actual path where you
# cloned the Alexa AVS sample app repository.
cd $ALEXA_AVS_SAMPLE_APP_PATH/samples/wakeWordAgent/src/

# Modify KittAiSnowboyWakeWordEngine.cpp and update SENSITIVITY at line 28.
# Modify KittAiSnowboyWakeWordEngine.cpp and set APPLY_FRONTEND to false at
# line 30.
make
```

* Run the wake word agent with engine set to `kitt_ai`!

**Universal model**
* Replace the hotword model in [Alexa AVS sample app](https://github.com/alexa/alexa-avs-sample-app) (after installation) with your universal model

```
# Please replace YOUR_UNIVERSAL_MODEL.umdl with the personal model you just
# created, and $ALEXA_AVS_SAMPLE_APP_PATH with the actual path where you
# cloned the Alexa AVS sample app repository.
cp YOUR_UNIVERSAL_MODEL.umdl $ALEXA_AVS_SAMPLE_APP_PATH/samples/wakeWordAgent/ext/resources/alexa.umdl
```

* Update `SENSITIVITY` in the [Alexa AVS sample app code](https://github.com/alexa/alexa-avs-sample-app/blob/master/samples/wakeWordAgent/src/KittAiSnowboyWakeWordEngine.cpp) and re-compile

```
# Please replace $ALEXA_AVS_SAMPLE_APP_PATH with the actual path where you
# cloned the Alexa AVS sample app repository.
cd $ALEXA_AVS_SAMPLE_APP_PATH/samples/wakeWordAgent/src/

# Modify KittAiSnowboyWakeWordEngine.cpp and update SENSITIVITY at line 28.
make
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

Currently Snowboy supports:

* all versions of Raspberry Pi (with Raspbian based on Debian Jessie 8.0)
* 64bit Mac OS X
* 64bit Ubuntu (12.04 and 14.04)
* iOS
* Android
* Pine64 (Debian Jessie 8.5, 3.10.102 BSP2)
* Intel Edison (Ubilinux based on Debian Wheezy 7.8)
* Samsung Artik (built with Fedora 25 for ARMv7)

It ships in the form of a **C++ library** with language-dependent wrappers
generated by SWIG. We welcome wrappers for new languages -- feel free to send a
pull request!

Currently we have built wrappers for:

* Java/Android
* Go (thanks to @brentnd)
* Node (thanks to @evancohen)
* Perl (thanks to @iboguslavsky)
* Python
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

* **resources/snowboy.umdl**: Universal model for the hotword "Snowboy". Set
SetSensitivity to 0.5 for better performance.
* **resources/alexa.umdl**: Universal model for the hotword "Alexa". Set
SetSensitivity to 0.5, and preferably set ApplyFrontend (only works on Raspberry
Pi) to true. This model is depressed.
* **resources/alexa/alexa_02092017.umdl**: Universal model for the hotword
"Alexa". This is still work in progress. Set SetSensitivity to 0.15.
* **resources/alexa/alexa-avs-sample-app/alexa.umdl**: Universal model for the
hotword "Alexa" optimized for [Alexa AVS sample app](https://github.com/alexa/alexa-avs-sample-app).
Set SetSensitivity to 0.6, and set ApplyFrontend (only works on Raspberry Pi)
to true. This is so far the best "Alexa" model we released publicly, when
ApplyFrontend is set to true.

## Precompiled node module

Snowboy is available in the form of a native node module precompiled for:
64 bit Ubuntu, MacOS X, and the Raspberry Pi (Raspbian 8.0+). For quick
installation run:

    npm install --save snowboy

For sample usage see the `examples/Node` folder. You may have to install
dependencies like `fs`, `wav` or `node-record-lpcm16` depending on which script
you use.

## Precompiled Binaries with Python Demo
* 64 bit Ubuntu [12.04](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/ubuntu1204-x86_64-1.2.0.tar.bz2)
  / [14.04](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/ubuntu1404-x86_64-1.2.0.tar.bz2)
* [MacOS X](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/osx-x86_64-1.2.0.tar.bz2)
* Raspberry Pi with Raspbian 8.0, all versions
  ([1/2/3/Zero](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/rpi-arm-raspbian-8.0-1.2.0.tar.bz2))
* Pine64 (Debian Jessie 8.5 (3.10.102)) ([download](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/pine64-debian-jessie-1.2.0.tar.bz2))
* Intel Edison (Ubilinux based on Debian Wheezy 7.8) ([download](https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/edison-ubilinux-1.2.0.tar.bz2))
  
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

### Ubuntu/Raspberry Pi/Pine64

First `apt-get` install `swig`, `sox`, `portaudio` and its Python binding `pyaudio`:

    sudo apt-get install swig3.0 python-pyaudio python3-pyaudio sox
    pip install pyaudio
    
Then install the `atlas` matrix computing library:

    sudo apt-get install libatlas-base-dev
    
Make sure that you can record audio with your microphone:

    rec t.wav
        
If you need extra setup on your audio (especially on a Raspberry Pi), please see the [full documentation](http://docs.kitt.ai/snowboy).

## Compile a Node addon
Compiling a node addon for Linux and the Raspberry Pi requires the installation of the following dependencies:

    sudo apt-get install libmagic-dev libatlas-base-dev

Then to compile the addon run the following from the root of the snowboy repository:

    node-pre-gyp clean configure build

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
