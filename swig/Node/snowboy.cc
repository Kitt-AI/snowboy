#include <nan.h>
#include <snowboy-detect.h>
#include <iostream>

class SnowboyDetect : public Nan::ObjectWrap {
  public:
    static NAN_MODULE_INIT(Init);

  private:
    explicit SnowboyDetect(const std::string& resource_filename,
                           const std::string& model_str);
    ~SnowboyDetect();

    static NAN_METHOD(New);
    static NAN_METHOD(Reset);
    static NAN_METHOD(RunDetection);
    static NAN_METHOD(SetSensitivity);
    static NAN_METHOD(GetSensitivity);
    static NAN_METHOD(SetAudioGain);
    static NAN_METHOD(UpdateModel);
    static NAN_METHOD(NumHotwords);
    static NAN_METHOD(SampleRate);
    static NAN_METHOD(NumChannels);
    static NAN_METHOD(BitsPerSample);
    static NAN_METHOD(ApplyFrontend);

    static Nan::Persistent<v8::Function> constructor;

    snowboy::SnowboyDetect* detector;
};

Nan::Persistent<v8::Function> SnowboyDetect::constructor;

SnowboyDetect::SnowboyDetect(const std::string& resource_filename,
                             const std::string& model_str) {
  try {
    this->detector = new snowboy::SnowboyDetect(resource_filename, model_str);
  } catch (std::runtime_error e) {
    Nan::ThrowError(e.what());
  }
}
SnowboyDetect::~SnowboyDetect() {
  if (this->detector) {
    delete this->detector;
  }
}

NAN_MODULE_INIT(SnowboyDetect::Init) {
  v8::Local<v8::FunctionTemplate> tpl = Nan::New<v8::FunctionTemplate>(New);
  tpl->SetClassName(Nan::New("SnowboyDetect").ToLocalChecked());
  tpl->InstanceTemplate()->SetInternalFieldCount(1);

  SetPrototypeMethod(tpl, "Reset", Reset);
  SetPrototypeMethod(tpl, "RunDetection", RunDetection);
  SetPrototypeMethod(tpl, "SetSensitivity", SetSensitivity);
  SetPrototypeMethod(tpl, "GetSensitivity", GetSensitivity);
  SetPrototypeMethod(tpl, "SetAudioGain", SetAudioGain);
  SetPrototypeMethod(tpl, "UpdateModel", UpdateModel);
  SetPrototypeMethod(tpl, "NumHotwords", NumHotwords);
  SetPrototypeMethod(tpl, "SampleRate", SampleRate);
  SetPrototypeMethod(tpl, "NumChannels", NumChannels);
  SetPrototypeMethod(tpl, "BitsPerSample", BitsPerSample);
  SetPrototypeMethod(tpl, "ApplyFrontend", ApplyFrontend);

  constructor.Reset(Nan::GetFunction(tpl).ToLocalChecked());
  Nan::Set(target, Nan::New("SnowboyDetect").ToLocalChecked(),
    Nan::GetFunction(tpl).ToLocalChecked());
}

NAN_METHOD(SnowboyDetect::New) {
  if (!info.IsConstructCall()) {
    Nan::ThrowError("Cannot call constructor as function, you need to use "
                    "'new' keyword");
    return;
  } else if (!info[0]->IsString()) {
    Nan::ThrowTypeError("resource must be a string");
    return;
  } else if (!info[1]->IsString()) {
    Nan::ThrowTypeError("model must be a string");
    return;
  }

  Nan::MaybeLocal<v8::Object> resource = Nan::To<v8::Object>(info[0]);
  Nan::MaybeLocal<v8::Object> model = Nan::To<v8::Object>(info[1]);
  Nan::Utf8String resourceString(resource.ToLocalChecked());
  Nan::Utf8String modelString(model.ToLocalChecked());
  SnowboyDetect* obj = new SnowboyDetect(*resourceString, *modelString);
  obj->Wrap(info.This());
  info.GetReturnValue().Set(info.This());
}

NAN_METHOD(SnowboyDetect::Reset) {
  SnowboyDetect* ptr = Nan::ObjectWrap::Unwrap<SnowboyDetect>(info.Holder());
  bool ret = ptr->detector->Reset();
  info.GetReturnValue().Set(Nan::New(ret));
}

NAN_METHOD(SnowboyDetect::RunDetection) {
  if (!info[0]->IsObject()) {
    Nan::ThrowTypeError("data must be a buffer");
    return;
  }

  Nan::MaybeLocal<v8::Object> buffer = Nan::To<v8::Object>(info[0]);
  char* bufferData = node::Buffer::Data(buffer.ToLocalChecked());
  size_t bufferLength = node::Buffer::Length(buffer.ToLocalChecked());

  std::string data(bufferData, bufferLength);

  SnowboyDetect* ptr = Nan::ObjectWrap::Unwrap<SnowboyDetect>(info.Holder());
  int ret = ptr->detector->RunDetection(data);
  info.GetReturnValue().Set(Nan::New(ret));
}

NAN_METHOD(SnowboyDetect::SetSensitivity) {
  if (!info[0]->IsString()) {
    Nan::ThrowTypeError("sensitivity must be a string");
    return;
  }

  Nan::MaybeLocal<v8::Object> sensitivity = Nan::To<v8::Object>(info[0]);
  Nan::Utf8String sensitivityString(sensitivity.ToLocalChecked());

  SnowboyDetect* ptr = Nan::ObjectWrap::Unwrap<SnowboyDetect>(info.Holder());
  ptr->detector->SetSensitivity(*sensitivityString);
}

NAN_METHOD(SnowboyDetect::ApplyFrontend) {
  Nan::Maybe<bool> applyFrontend= Nan::To<bool>(info[0]);
  bool applyFrontendBool=applyFrontend.FromJust();

  SnowboyDetect* ptr = Nan::ObjectWrap::Unwrap<SnowboyDetect>(info.Holder());
  ptr->detector->ApplyFrontend(applyFrontendBool);
}

NAN_METHOD(SnowboyDetect::GetSensitivity) {
  SnowboyDetect* ptr = Nan::ObjectWrap::Unwrap<SnowboyDetect>(info.Holder());
  std::string sensitivity = ptr->detector->GetSensitivity();
  info.GetReturnValue().Set(Nan::New(sensitivity).ToLocalChecked());
}

NAN_METHOD(SnowboyDetect::SetAudioGain) {
  if (!info[0]->IsNumber()) {
    Nan::ThrowTypeError("gain must be a number");
    return;
  }

  Nan::MaybeLocal<v8::Number> gain = Nan::To<v8::Number>(info[0]);
  SnowboyDetect* ptr = Nan::ObjectWrap::Unwrap<SnowboyDetect>(info.Holder());
  ptr->detector->SetAudioGain(gain.ToLocalChecked()->Value());
}

NAN_METHOD(SnowboyDetect::UpdateModel) {
  SnowboyDetect* ptr = Nan::ObjectWrap::Unwrap<SnowboyDetect>(info.Holder());
  ptr->detector->UpdateModel();
}

NAN_METHOD(SnowboyDetect::NumHotwords) {
  SnowboyDetect* ptr = Nan::ObjectWrap::Unwrap<SnowboyDetect>(info.Holder());
  int numHotwords = ptr->detector->NumHotwords();
  info.GetReturnValue().Set(Nan::New(numHotwords));
}

NAN_METHOD(SnowboyDetect::SampleRate) {
  SnowboyDetect* ptr = Nan::ObjectWrap::Unwrap<SnowboyDetect>(info.Holder());
  int sampleRate = ptr->detector->SampleRate();
  info.GetReturnValue().Set(Nan::New(sampleRate));
}

NAN_METHOD(SnowboyDetect::NumChannels) {
  SnowboyDetect* ptr = Nan::ObjectWrap::Unwrap<SnowboyDetect>(info.Holder());
  int numChannels = ptr->detector->NumChannels();
  info.GetReturnValue().Set(Nan::New(numChannels));
}

NAN_METHOD(SnowboyDetect::BitsPerSample) {
  SnowboyDetect* ptr = Nan::ObjectWrap::Unwrap<SnowboyDetect>(info.Holder());
  int bitsPerSample = ptr->detector->BitsPerSample();
  info.GetReturnValue().Set(Nan::New(bitsPerSample));
}


NODE_MODULE(SnowboyDetect, SnowboyDetect::Init)
