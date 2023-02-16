
<h1 align='center'>CartoonGan for iOS with TensorFlow Lite</h1>


The **CartoonGan** model can be found in [tfhub](https://tfhub.dev/sayakpaul/lite-model/cartoongan/dr/1) and was developed by [Sayak Paul](https://tfhub.dev/sayakpaul). In this repo we build an iOS application to perform the cartoonization with an iPhone.

https://www.dropbox.com/s/7x3obx9egks13qi/video-demo-image.MP4?dl=0

## Objectives
### Dall-E Open AI
- https://labs.openai.com/
- https://platform.openai.com/docs/guides/images/
- https://github.com/dylanshine/openai-kit
### TensorFlow Lite Swift API
- Use the [TensorFlow Lite Swift API](https://www.tensorflow.org/lite/guide/ios)
- Understand the pre & post processing of images with Swift, using the [CoreGraphics](https://developer.apple.com/documentation/coregraphics) framework. The main challenge is that the TensorflowLite Swift API takes the raw Data and it needs a lot of pre/post processing and understanding of the images and its content.
- **Link**
    - https://www.tensorflow.org/lite/examples/style_transfer/overview
    - https://github.com/rusito-23/CartoonGan-iOS
        - https://tfhub.dev/sayakpaul/lite-model/cartoongan/int8/1
        - https://tfhub.dev/s?q=Style%20Transfer
    

### Other
- [Search Google](https://www.google.com/search?q=ai+cartoon+face+generator+API&rlz=1C5CHFA_enVN912VN912&sxsrf=AJOqlzXY-sGqHUNxgK2mLm48yjByjZwHTQ%3A1676127189493&ei=1avnY7TlHcH5wQPt0a6wBQ&ved=0ahUKEwj0o-mt3I39AhXBfHAKHe2oC1YQ4dUDCA8&uact=5&oq=ai+cartoon+face+generator+API&gs_lcp=Cgxnd3Mtd2l6LXNlcnAQAzIHCCEQoAEQCjIHCCEQoAEQCjILCCEQFhAeEPEEEB0yCAghEBYQHhAdMggIIRAWEB4QHToKCAAQRxDWBBCwAzoJCAAQFhAeEPEEOgYIABAWEB46BQgAEIYDSgQIQRgAUHZYvgdgvgloAXABeACAAdMBiAHBBJIBBTAuMi4xmAEAoAEByAEIwAEB&sclient=gws-wiz-serp)
- Mid Journey
    - Don’t support API
    - Generate image via Discord: https://discord.gg/midjourney
- [Cartoonify Tag](https://github.com/topics/cartoonify)


## App

The app is built with **UIKit** using programmatic components only. The class [CartoonGanModel](CartoonGan/CartoonGanModel/CartoonGanModel.swift) contains the logic to perform inference, pre/post processing and error handling for all of these cases.

To get the app started
 - run `pod install` to install the dependencies.
