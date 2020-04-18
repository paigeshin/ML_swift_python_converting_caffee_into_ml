# swift_python_Make_MLmodel_using_caffemodel

# How to make `pre-trained model` to `ML model`

# Link

https://www.notion.so/Python-mlmodel-converter-21320d7b1af2491bab1be1069c944525
https://www.notion.so/Advanced-ML-9c5b7c737db74d1da6c424c093b58198

# app icon

https://www.freepik.com/

https://makeappicon.com/

# Model Zoo

https://github.com/BVLC/caffe/wiki/Model-Zoo 

=> 여기서 엄청나게 많은 모델을 제공받을 수 있다.

### Necessary files to make MLModel which will be used on App Development

- caffemodel (.caffemodel)
- file that describes the architecture of the caffe model (.deploy.prototxt)
- labels (.txt)

### Conversion Workflow

Model Source(.Caffe) → xCode → Your App 

### What we are going to use

- Oxford 102 Flower Dataset

### Installing CoremlTools using Python PIP

[https://pypi.org/project/pip/](https://pypi.org/project/pip/)

- PIP - Python package manager

    ### 설치 ###
        sudo python get-pip.py #이게 안되면 아래 line을 실행 
        curl 'https://bootstrap.pypa.io/get-pip.py' > get-pip.py && sudo python get-pip.py
    
        ### 버전 확인 ### 
        pip -v
    
        ### 환경구축 ###
        sudo pip install virtualenv
        mkdir Environments
        cd Environments
        virtualenv --python=/usr/bin/python2.7 python27 #virtual env가 python 2.7로 돌아가게 만듬 
        #위에 것이 안되면 아래 코드로 작동
        virtualenv -p=/usr/bin/python2.7 python27
        
    
        source python27/bin/python
        #위에 것이 안되면
        ./python27/bin/python #이제 터미널이 python27 env으로 진행.
        #기본적으로 python 2.7을 이용하기 위해서 하는 방법이다.
        #python은 버전에 매우 민감하기 때문에 특정 모듈을 사용하고자 할 때 이렇게 버전을 바꿔갈 수 있음.
        
        #빠져나오기 
        deactivate 

- 내가 편할려고 bash_profile에 추가

        alias ML='cd /Users/grosso/Environments;source python27/bin/activate;'

- python 환경 2.7일 때

        #ML tool 설치
        pip install -U coremltools
        
        #설치 중 에러 발생
        sudo easy_install nose
        sudo easy_install tornado

### `CafeModel` to `MLModel`

[https://pypi.org/](https://pypi.org/)

- Caffe Model 을 Core ML 로 바꾸기

        import coremltools
        
        #p1 - caffemodel
        #p2 - file that describes the architecture of the caffe model
        caffe_model = ('oxford102.caffemodel', 'deploy.prototxt')
        
        labels = 'flower-labels.txt'
        
        coreml_model = coremltools.converters.caffe.convert(
            caffe_model,
            class_labels = labels,
            image_input_names = 'data'
        )
        
        coreml_model.save('FlowerClassifier.mlmodel')

⇒ "반드시 실행하기 전에 " `cd /Users/grosso/Environments; source python27/bin/activate;` 를 실행해서 python 2.7 버전으로 맞춰줘야 한다.


# iOS에서 mlmodel 사용

### android에서는 ML을 써본적은 없지만 아마 mlmodel로 코딩할 것이라고 추측됨.

### 만들어진 mlmodel을 xcode project에 가져온다. -> 자동으로 class가 만들어짐.
- 파일이 하도 커서 xCode에서 곧바로 파일 추가가 안되더라도 조금 기다리자


## Depenency
    
    pod 'Alamofire', '~> 5.1'
    pod 'SwiftyJSON'


### 기본

- CIImage
- VNCoreModel
- VNCoreRequest
- VNImageRequestHandler


        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let userPickedImage = info[.editedImage] as? UIImage {
                guard let convertedImage = CIImage(image: userPickedImage) else {fatalError("Cannot convert to CIImage")}
                detect(image: convertedImage)
                imageView.image = userPickedImage
            }
            
            
            
            imagePicker.dismiss(animated: true, completion: nil)
            
        }
        
        func detect(image: CIImage){
            
            guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else { fatalError("Cannot import model") }
                
            let request = VNCoreMLRequest(model: model) {(request, error) in
                let classification = request.results?.first as? VNClassificationObservation
                self.navigationController!.title = classification?.identifier.capitalized
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
            
        }

# SwiftyJson & Almofire

    func requestInfo(flowerName: String) {
        
        let parameters : [String: String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
        ]
        
        AF.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { (response) in
            
            print(response.result)
            
            //json parsing using swifty json
            
             let flowerJSON: JSON
            
            switch response.result {
            case .success(let value):
                flowerJSON = JSON(value)
                
                print("flowerJSON: \(flowerJSON)")
                
                let pageId = flowerJSON["query"]["pageids"][0].stringValue
                
                print(flowerJSON["query"])
                
                let flowerDescription = flowerJSON["query"]["pages"][pageId]["extract"].stringValue
                
                let flowerImageURL = flowerJSON["query"]["pages"][pageId]["thumbnail"]["source"].stringValue
                
                self.imageView.sd_setImage(with: URL(string: flowerImageURL))
                
                self.label.text = flowerDescription
                
            case .failure(let error):
                print(error)
            }
        }
