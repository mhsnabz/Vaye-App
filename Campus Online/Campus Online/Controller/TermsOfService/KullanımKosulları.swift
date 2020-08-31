//
//  KullanımKosullarıViewController.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 25.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit

class KullanımKosulları: UIViewController {
    
    
    let htmlString = """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset='utf-8'>
      <meta name='viewport' content='width=device-width'>
      <title>Terms &amp; Conditions</title>
      <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
    </head>
    <body>
    <strong>Hizmet Şartları</strong> <p>
                 Uygulamayı indirerek veya kullanarak, bu terimler sizin için otomatik olarak geçerli olacaktır
                  bu nedenle uygulamayı kullanmadan önce bunları dikkatlice okuduğunuzdan emin olmalısınız.Uygulamanın herhangi bir bölümünü
                  veya ticari markalarımızı hiçbir şekilde kopyalayamaz veya değiştiremezsiniz.Uygulamanın kaynak kodunu çıkarılmasına izin verilmez ve ayrıca uygulamayı
                  başka dillere çevirmeye veya türev sürümler oluşturmaya çalışmamalısınız.Uygulamanın kendisi ve tüm ticari markalar, telif hakkı,
                  veritabanı hakları ve bununla ilgili diğer fikri mülkiyet hakları hala uygulama kurucularına aittir.
                </p> <p>
                  Uygulamanın kurucuları uygulamanın mümkün olduğunca yararlı ve verimli olmasını sağlamayı taahhüt eder.
                  Bu nedenle, herhangi bir zamanda ve herhangi bir nedenle uygulamada değişiklik yapma veya
                  hizmetleri için ücret alma hakkımızı saklı tutarız. Size tam olarak ne için ödeme yaptığınızı
                  açıkça belirtmeden, uygulama veya hizmetleri için hiçbir zaman ücret almayacağız.
                </p> <p>
                İste uygulaması, Hizmetimizi sağlamak için bize sağladığınız kişisel verileri saklar ve işler.
                   Telefonunuzu ve uygulamaya erişiminizi güvenli tutmak sizin sorumluluğunuzdadır.
                   Bu nedenle, cihazınızın resmi işletim sistemi tarafından uygulanan yazılım kısıtlamalarını ve
                   sınırlamalarını kaldırma işlemi olan telefonunuzu jailbreak veya Root yapmamanızı öneririz.
                   Telefonunuzu kötü amaçlı yazılımlara / virüslere / kötü amaçlı programlara karşı savunmasız
                   bırakabilir, telefonunuzun güvenlik özelliklerinden
                  ödün verebilir ve iste uygulamasının düzgün veya hiç çalışmadığı anlamına gelebilir.
                </p>
                true
                <div><p>
                   Uygulama, kendi Şartlar ve Koşullarını beyan eden üçüncü taraf hizmetlerini kullanmaktadır.
                  </p> <p>
                   Uygulama tarafından kullanılan üçüncü taraf hizmet sağlayıcılarının Şartlar ve Koşullarına bağlantı
                  </p> <ul><li><a href="https://policies.google.com/terms" target="_blank">Google Play Services</a></li><!----><li><a href="https://firebase.google.com/terms/analytics" target="_blank">Google Analytics for Firebase</a></li><li><a href="https://firebase.google.com/terms/crashlytics" target="_blank">Firebase Crashlytics</a></li><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----></ul></div> <p>
                 Iste uygulamasının sorumluluk almayacağı bazı şeyler olduğunu bilmelisiniz.
                  Uygulamanın bazı işlevleri, uygulamanın etkin bir internet bağlantısına sahip olmasını gerektirir.
                  Bağlantı Wi-Fi olabilir veya mobil ağ sağlayıcınız tarafından sağlanabilir, ancak Iste uygulaması,
                  Wi-Fi'ye erişiminiz yoksa ve herhangi bir ağınız yoksa,
                  uygulamanın tam işlevsellikte çalışmaması için sorumluluk alamaz.
                </p> <p></p> <p>
               
                  Uygulamayı Wi-Fi olan bir alanın dışında kullanıyorsanız mobil ağ sağlayıcınızla yaptığınız
                  sözleşme şartlarının yine de geçerli olacağını unutmayın. Sonuç olarak, diğer üçüncü taraf masrafları gibi,
                   uygulamaya erişirken bağlantı süresi boyunca veri maliyeti için mobil sağlayıcınız tarafından
                   ücretlendirilebilirsiniz. Uygulamayı kullanırken, veri dolaşımını kapatmadan uygulamayı kendi
                   bölgenizin dışında (yani bölge veya ülke) kullanırsanız, dolaşım veri ücretleri de dahil olmak
                   üzere bu tür masraflar için sorumluluğu kabul edersiniz. Uygulamayı kullandığınız cihaz için
                   fatura ödeyici değilseniz, uygulamayı kullanmak için fatura ödeyenden izin aldığınızı kabul ettiğimizi lütfen unutmayın.
                </p> <p>
                  
                  Aynı hatlar boyunca, Iste uygulaması hiçbir zaman uygulamayı kullanma şeklinizin sorumluluğunu alamaz,
                  yani cihazınızın şarjlı kaldığından emin olmanız gerekir . pil biterse ve Hizmeti kullanmak için
                  açamıyorsanız,Iste Uygulaması sorumluluk kabul etmez
                </p> <p>
                  Gargisoft’un uygulamanın kullanımıyla ilgili sorumluluğuyla ilgili olarak, uygulamayı kullanırken,
                    uygulamanın her zaman güncel ve doğru olmasını sağlamaya çalışmamıza rağmen,
                  size bilgi verebilmemiz için bize bilgi sağlama konusunda üçüncü taraflara güveniyoruz.Iste uygulaması,
                   tamamen uygulamanın bu işlevselliğine güvenen bir sonucu olarak, doğrudan veya
                   dolaylı, herhangi bir kayıp için hiçbir sorumluluk kabul etmez.
                </p> <p>
                 Bir noktada uygulamayı güncellemek isteyebiliriz. Uygulama şu anda Android & iOS  her iki sistem
                  için (ve uygulamanın kullanılabilirliğini genişletmeye karar verdiğimiz herhangi bir ek sistem için)
                   gereksinimler değişebilir ve uygulamayı kullanmaya devam etmek istiyorsanız güncellemeleri indirmeniz gerekir.


                   Iste Uygulamsı her zaman güncelleneceğini garanti etmiyor.Bununla birlikte, size teklif edildiğinde her zaman uygulama güncellemelerini
                   kabul edeceğinize söz verirsiniz, Uygulamayı sağlamayı bırakabiliriz ve fesih bildirimi vermeden herhangi bir zamanda uygulamayı sonlandırabiliriz.
                   Size aksini söylemedikçe, herhangi bir fesih üzerine,
                   (a) bu şartlarda size verilen haklar ve lisanslar sona erecektir;
                                     
                   (b) uygulamayı kullanmayı bırakmanız ve (gerekirse) cihazınızdan silmeniz gerekir.
                </p> <p><strong>Bu Hüküm ve Koşullardaki Değişiklikler</strong></p> <p>
                  Şartlar ve Koşullarımızı zaman zaman güncelleyebiliriz. Bu nedenle, değişiklikler için bu sayfayı
                  periyodik olarak gözden geçirmeniz önerilir.
                  bu sayfada yeni Şartlar ve Koşullar yayınlayarak değişiklikleri bildireceğiz.
                </p> <p>
                  Bu hüküm ve koşullar 2020-04-13 tarihinden itibaren geçerlidir
                </p> <p><strong>Bize Ulaş</strong></p> <p>
                 Şartlar ve Koşullarımız hakkında sorularınız veya önerileriniz varsa, mhsnabz@yahoo.com.tr adresinden bizimle iletişime geçmekten çekinmeyin.

                </p> <p>
                 
    </body>
    </html>
      
    """
    let webView : UITextView = {
          let w = UITextView()
          w.isEditable = false
          w.font = UIFont.systemFont(ofSize: 14)
          return w
      }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "Hizmet Koşulları"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "down-arrow"), style: .plain, target: self, action: #selector(dismis))
        view.addSubview(webView)
        webView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        webView.attributedText = htmlString.htmlToAttributedString
        // Do any additional setup after loading the view.
    }
    @objc func dismis(){
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
