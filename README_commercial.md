# Common Questions for a Commercial Application

You are looking for a way to put Snowboy in a commercial application. We have compiled a large collection of common questions from our customers all over the world in various industries. 


## Universal models (paid) vs. personal models (free)

Personal models:

* are the models you downloaded from https://snowboy.kitt.ai or using our `/train` SaaS API.
* are good for quick demos
* are built with only 3 voice samples
* are not noise robust and you'll get a lot of false alarms in real environment
* only work on your own voice or a very similar voice, thus is speaker dependent
* are free

Universal models:

* are built using a lot more voice samples (at least thousands)
* take effort to collect those voice samples
* take a lot of GPU time to train
* are more robust against noise
* are mostly speaker independent (with challenges on children's voice and accents)
* cannot be built by yourself using the web interface or the SaaS API
* cost you money

### FAQ for universal & personal models

Q: **If I record multiple times on snowboy.kitt.ai, can I improve the personal models?**  
A: No. Personal models only take 3 voice samples to build. Each time you record new voices, the previous samples are overwritten and not used in your current model. 


Q: **How can I get a universal model for free?**  
A: The *one and only* way: Ask 500 people to log in to snowboy.kitt.ai, contribute their voice samples to a particular hotword, then ask us to build a universal model for that hotword.

Q: **Can I use your API to collect voices from 500 people and increment the sample counter from snowboy.kitt.ai?**  
A: No. The [SaaS](https://github.com/kitt-ai/snowboy#hotword-as-a-service) API is separate from the website.

Q: **How long does it take to get a universal model?**  
A: Usually a month.

## Licensing


### Explain your license again?

Everything on Snowboy's GitHub repo is Apache licensed, including various sample applications and wrapper codes, though the Snowboy library is binary code compiled against different platforms. 

With that said, if you built an application from https://github.com/kitt-ai/snowboy or personal models downloaded from https://snowboy.kitt.ai, you don't need to pay a penny.

If you want to use a universal model with your own customized hotword, you'll need an **evaluation license** and a **commercial license**.

### Evaluation license

Each hotword is different. When you train a universal model with your own hotword, nobody can guarantee that it works on your system without any flaws. Thus you'll need to get an evaluation license first to test whether your universal model works for you.

An evaluation license:

* gives you a 90 day window to evaluate the universal model we build for you
* costs you money

**Warning: an evaluation license will expire after 90 days. Make sure you don't use the model with evaluation license in production systems.** Get a commercial license from us for your production system.

#### Evaluation license FAQ

Q: **How much does it cost?**  
A: A few thousand dollars.

Q: **Can I get a discount as a {startup, student, NGO}?**  
A: No. Our pricing is already at least half of what others charge.

Q: **How can you make sure your universal model works for me?**  
A: We simply can't. However we have a few sample universal models from our GitHub [repo](https://github.com/Kitt-AI/snowboy/tree/master/resources), including "alexa.umdl", "snowboy.umdl", and "smart_mirror.umdl". The "alexa.umdl" model is enhanced with a lot more data and is not a typical case. So pay attention to test "snowboy.umdl" and "smart_mirror.umdl". They offer similar performance to your model.


### Commercial license

After evaluation, if you feel want to go with Snowboy, you'll need a commercial license to deploy it. We usually charge a flat fee per unit of hardware you sell.

#### Commercial license FAQ

Q: **Is it a one-time license or subscription-based license?**  
A: It's a perpetual license for each device. Since the Snowboy library runs *offline* on your device, you can run it forever without worrying about any broken and dependent web services.

Q: **What's your pricing structure?**  
A: We have tiered pricing depending on your volume. We charge less if you sell more.

Q: **Can you give me one example?**  
A: For instance, if your product is a talking robot with a $300 price tag, and you sell at least 100,000 units per year, we'll probably charge you $1 per unit once you go over 100,000 units. If your product is a smart speaker with a $30 price tag, we won't charge you $1, but you'll have to sell a lot more to make the business sense to us.

Q: **I plan to sell 1000 units a year, can I license your software for $1 per unit?**  
A: No. In that way we only make $1000 a year, which is not worth the amount of time we put on your hotword.

Q: **I make a cellphone app, not a hardware product, what's the pricing structure?**  
A: Depends on how you generate revenue. For instance, if your app is priced at $1.99, we'll collect cents per paid user, assuming you have a large user base. If you only have 2000 paid users, we'll make a revenue of less than a hundred dollars and it won't make sense to us.


### What's the process of getting a license?

1. Make sure Snowboy can run on your system
2. Reach out to us with your hotword name, commercial application, and target market
3. Discuss with us about **commercial license** fee to make sure our pricing fits your budget
4. Sign an evaluation contract, pay 50% of invoice
5. We'll train a universal model for you and give you an **evaluation license** of 90 days
6. Test the model and discuss how we can improve it
7. If you decide to go with it, get a commercial license from us

## General Questions

### What language does Snowboy support?

We support North American English and Chinese the best. We can deal with a bit of Indian accents as well. For other languages, we'll need to first listen to your hotword (please send us a few .wav voice samples) before we can engage.

### How many voice samples do you need?

Usually 1500 voice samples from 500 people to get started. The more the better. If your hotword is in English, we can collect the voice samples for you. Otherwise you'll need to collect it yourself and send to us.

### What's the format on voice samples?

16000Hz sample rate, 16 bit integer, mono channel, .wav files.

### Does Snowboy do: AEC, VAD, Noise Suppression, Beam Forming?

Snowboy has a weak support for VAD and noise suppression, as we found some customers would use Snowboy without a microphone array. Snowboy is not a audio frontend processing toolkit thus does not support AEC and beam forming.

If your application wants to support far-field speech, i.e., verbal communication at least 3 feet away, you'll need a microphone array to enhance incoming speech and reduce noise. Please do not reply on Snowboy to do everything.

### Can you compile Snowboy for my platform?

If your platform is not listed [here](https://github.com/Kitt-AI/snowboy/tree/master/lib), and you want to get a commercial license from us, please contact us with your toolchain, hardware chip, RAM, OS, GCC/G++ version. Depending on the effort, we might charge an NRE fee for cross compiling.

### Contact

If this document doesn't cover what's needed, feel free to reach out to us at snowboy@kitt.ai