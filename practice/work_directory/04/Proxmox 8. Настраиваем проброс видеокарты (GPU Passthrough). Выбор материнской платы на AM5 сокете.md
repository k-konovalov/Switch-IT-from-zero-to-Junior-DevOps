---
title: "Proxmox 8. Настраиваем проброс видеокарты (GPU Passthrough). Выбор материнской платы на AM5 сокете"
source: "https://habr.com/ru/articles/794568/"
author:
  - "[[Денис]]"
published: 2024-03-19
created: 2025-11-02
description: "Уже прошел год как вышел Debian 12 Bookworm и, основанный на нем, Proxmox 8 . Несмотря на тот факт, что мои предыдущие статьи по пробросу дискретной Видеокарты в виртуальную машину , в кол-ве 4-х на..."
tags:
  - "clippings"
---
![](https://habrastorage.org/r/w1560/webt/et/ir/x8/etirx8p9dcqxckaqhxeqs0bdfau.png)  
  
Уже прошел год как вышел [Debian 12 Bookworm](https://www.debian.org/releases/bookworm/) и, основанный на нем, [Proxmox 8](https://www.proxmox.com/en/services/videos/proxmox-virtual-environment/what-s-new-in-proxmox-ve-8-0). Несмотря на тот факт, что [мои предыдущие статьи](https://habr.com/ru/articles/743756/) по пробросу [дискретной Видеокарты в виртуальную машину](https://pve.proxmox.com/wiki/PCI_Passthrough), в кол-ве 4-х на Хабре, частично все еще актуальны для последней версии [Proxmox](https://www.proxmox.com/en/), в тематических чатах регулярно поступали обращения обновить статью, а так же выяснилось что, у тех кто пользуется такими инструкциями, есть определенное непонимание в нюансах, из-за чего приходится проходить вместе с ними всю цепочку действий заново.  
  

### Введение

  
Здесь я хочу отметить, что настоящая статья тематически будет поделена на 3 части:  
  
- Нюансы выбора железа на АМ5 сокете, которые могут быть не всем интересны и, потому, большая ее часть будет под спойлером;
- Актуализированная инструкция по настройке проброса **дискретной видеокарты** ([GPU Passthrough](https://pve.proxmox.com/wiki/PCI_Passthrough)) с учетом имеющихся под рукой у меня конфигураций железа на [AM5](https://ru.wikipedia.org/wiki/Socket_AM5) B650 и [LGA1151v2 H370](https://habr.com/ru/articles/513964/)  
	**Видеопрезентация проброса видеокарт (GPU Passthrough)**
	Видеоролик с результатами проброса mobile GTX1660ti Max-Q в ноутбуке:  
	  
	Видеоролик с результатами проброса GTX1070 на десктопе:  
	  
	![](https://www.youtube.com/watch?v=wjlmWHJiEug)
- Все выжимки и инструкции по сопутствующей настройке [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) из трех первых моих статей для гипервизора [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview), а так же свежий опыт, которым могу с Вами поделиться.
  

### 1\. Выбор железа на AM5 сокете

**Выбор железа на AM5 сокете. Личный опыт и мысли вслух.**

Дополнительным фактором, благодаря которому и появилась эта статья, стал апгрейд моей платформы, которая эксплуатировалась с конца 2018года, а в общих чертах не менялась с 2016 года:  
  

> - Процессор — [Intel Core i7 8700k](https://ark.intel.com/content/www/us/en/ark/products/126684/intel-core-i7-8700k-processor-12m-cache-up-to-4-70-ghz.html)
> - Материнская плата — [AsRock Z390M Pro4](https://www.asrock.com/MB/Intel/Z390M%20Pro4/index.ru.asp)
> - ОЗУ — Corsair DDR4 16Gb 2400MHz pc-19200 Vengeance LPX Black (CMK16GX4M1A2400C14) х4
> - Система охлаждения — [Arctic Cooling Liquid Freezer 120](http://arctic-m.com/goods/arctic-liquid-freezer-120/)
> - Видеокарта — [INNO3D GeForce GTX 1070 iChill X4](https://youtu.be/-MpVpa34AZE)
> - RAID-контроллер — [LSI 9211-8i](https://www.ixbt.com/storage/lsi-sas9211-8i.shtml)
> - Жесткий диск — [WD Red WD40EFRX, 4Тб, HDD, SATA III, 3.5"](https://3dnews.ru/810882/page-2.html) х8
> - SSD диск — [Kingston A400 2.5" 480Gb SATA III TLC SA400S37/480G](https://www.kingston.com/en/memory/search?partid=SA400S37/480G)
> - Блок питания — THERMALTAKE TR2 TRX-850M Bronze, 850Вт, 135мм, черный, retail
> - Корпус — [Fractal Design Node 804 черный (mATX)](https://www.fractal-design.com/products/cases/node/node-804/black/)
> - Монитор — [27" Dell UltraSharp U2713HM](https://www.displayspecifications.com/en/model/6a897)

Проанализировав конфигурацию, а так же имевшиеся в наличие финансы, было принято решение заменить первые 4 позиции в списке. Вопрос о выборе платформы в январе сего года я решил просто: мне был нужен [ПК](https://ru.wikipedia.org/wiki/%D0%9F%D0%B5%D1%80%D1%81%D0%BE%D0%BD%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BA%D0%BE%D0%BC%D0%BF%D1%8C%D1%8E%D1%82%D0%B5%D1%80), у которого [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80) имеет одинаковые ядра/потоки числом более 8/16 на современной долгоиграющей платформе. Таким образом выбор пал на [AMD](https://ru.wikipedia.org/wiki/AMD) [AM5 сокет](https://ru.wikipedia.org/wiki/Socket_AM5), который сейчас находится в начале своего жизненного пути, по заявлением представителей [ru.wikipedia.org/wiki/AMD](https://ru.wikipedia.org/wiki/AMD), а значит в будущем можно будет заменить только [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80) и получить апгрейд, в то время как [Intel](https://ru.wikipedia.org/wiki/Intel) под [LGA 1700](https://ru.wikipedia.org/wiki/LGA_1700) выпустила последнюю линейку [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80) на 14-м поколении, и новых камней, на этом сокете, уже не будет. Кроме того мне не понятно как отделять производительные ядра в гипервизоре [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview) от энергоэффективных для [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0), если я их пробрасываю как host?  
  
Таким образом выбор был сделан в пользу в меру энергоэффективного [AMD Ryzen 9 7900](https://www.amd.com/en/products/apu/amd-ryzen-9-7900), который при покупке пришлось заменить на [AMD Ryzen 9 7900X](https://www.amd.com/en/products/cpu/amd-ryzen-9-7900x), из-за того что в рознице последний стоил на 5 тыс. дешевле версии без X. Однако наибольшей проблемой, для меня, стал выбор материнской платы.  
  
**1.1 Поиск и выбор материнской платы на [AM5 сокете](https://ru.wikipedia.org/wiki/Socket_AM5).**  
Помятую о том, как в 2018м году мне пришлось поменять 3 материнские платы, прежде чем на искомой завелся [GPU Passthrough](https://pve.proxmox.com/wiki/PCI_Passthrough), то в этот раз я решил подойти основательно с двух сторон:  
  
**1.1.1 Поиск материнской платы на X670/B650 чипсете форм-фактора [mATX](https://ru.wikipedia.org/wiki/MicroATX)**  
В крайнем случае я готов был взять даже взять плату форм-фактора [mini-ITX](https://ru.wikipedia.org/wiki/Mini-ITX), но последнюю все же не хотелось, т.к. у современных [mini-ITX](https://ru.wikipedia.org/wiki/Mini-ITX) плат всего 2 SATA разъема, а так же отсутствует еще один слот для установки имеющегося SATA/SAS RAID-контроллера [LSI 9211-8i](https://www.ixbt.com/storage/lsi-sas9211-8i.shtml), с учетом ее характеристик, возможностей и расположения элементов. Надо сказать что для домашнего сервера мой корпус [Fractal Design Node 804 черный (mATX)](https://www.fractal-design.com/products/cases/node/node-804/black/), в котором можно разместить до 10 HDD 3.5" и еще 2-3 [SSD](https://ru.wikipedia.org/wiki/%D0%A2%D0%B2%D0%B5%D1%80%D0%B4%D0%BE%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D1%8C) / [HDD](https://ru.wikipedia.org/wiki/%D0%96%D1%91%D1%81%D1%82%D0%BA%D0%B8%D0%B9_%D0%B4%D0%B8%D1%81%D0%BA) 2.5", меня полностью устраивает.  
  
Тем, кому будет актуальна тема поиска и сравнение современных, актуальных материнских плат на [AMD](https://ru.wikipedia.org/wiki/AMD) на чипсетах [AM5 сокета](https://ru.wikipedia.org/wiki/Socket_AM5), включая серверные варианты, будет небезынтересно узнать, что [в сети в открытом доступе есть файл с полным перечнем, на текущий момент, таких плат](https://docs.google.com/spreadsheets/d/1NQHkDEcgDPm34Mns3C93K6SJoBnua-x9O-y_6hv8sPs/edit#gid=2064683589), а так же их полным и исчерпывающим перечнем их характеристик, благодаря чему их удобно сравнивать между собой.  
  
На что я Вас призываю обратить внимание при покупке материнской платы:  
  
- питание. Если планируется использовать мощный [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80) с фактическим лимитом мощности (энергопотреблением) превышающим 100Вт, то необходимо что бы именно линий питания было больше 12 в любых вариантах, например: 6х2+2, 4х3+2+1 и т.д. и т.п.
- число слоев в плате 6 шт. и выше, это так же сказывается положительно при разгоне [ОЗУ](https://ru.wikipedia.org/wiki/%D0%9E%D0%BF%D0%B5%D1%80%D0%B0%D1%82%D0%B8%D0%B2%D0%BD%D0%B0%D1%8F_%D0%BF%D0%B0%D0%BC%D1%8F%D1%82%D1%8C) и стабильности работы такого разгона, т.е. если у Вас плата 4 слоя, то я бы не рекомендовал гнать память вообще, если 6 слоев, то не стоит брать более 2-х планок [ОЗУ](https://ru.wikipedia.org/wiki/%D0%9E%D0%BF%D0%B5%D1%80%D0%B0%D1%82%D0%B8%D0%B2%D0%BD%D0%B0%D1%8F_%D0%BF%D0%B0%D0%BC%D1%8F%D1%82%D1%8C) и гнать их выше 6000МГц, если же у Вас 8 и более, то можно брать 4 планки [ОЗУ](https://ru.wikipedia.org/wiki/%D0%9E%D0%BF%D0%B5%D1%80%D0%B0%D1%82%D0%B8%D0%B2%D0%BD%D0%B0%D1%8F_%D0%BF%D0%B0%D0%BC%D1%8F%D1%82%D1%8C) и/или гнать их по частоте шины выше 6000МГц. Все это справедливо для текущего чипсета X670/B650/A620.
- Наличие радиатора охлаждения на [цепях питания VRM](https://habr.com/ru/sandbox/177044/), [в случае если планируется на ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80) подавать большие мощности, порядка 100Вт и выше.
  
Закончить раздел я хочу представив видео на английском о тестировании 35 материнских плат на на [AM5 сокете](https://ru.wikipedia.org/wiki/Socket_AM5):  
  

**Тест и обзор 35 материнских плат на AM5 сокете**

  
**1.1.2 Поиск плат поиск материнской платы на X670/B650 чипсете, которые поддерживают работу [VFIO/IOMMU](https://habr.com/ru/companies/flant/articles/751746/)**  
Здесь мне пришлось долго и упорно искать в сети успешные и не очень истории проброса видеокарт в виртуальную машину, так что эту информацию стоит оценивать критически, потому что, по сути, это компоновка чужого опыта, который может быть ошибочным. Дополнительно нужно отметить, что если у Вас Linux выдает картину, при которой [IOMMU](https://ru.wikipedia.org/wiki/IOMMU) групп мало, а оборудования в них много, то не спешите отчаиваться и лезть в Linux конфиги и компиляцию патчей для ядра. Шутка. Эта проблема, обыкновенно, решается обновлением [BIOS (UEFI)](https://habr.com/ru/articles/404511/) на более свежую версию.  
  
На текущий момент мне известно несколько вариантов найденных в сети моделей материнских плат, которые на [AM5 сокете](https://ru.wikipedia.org/wiki/Socket_AM5) поддерживают с высокой долей вероятности проброс видеокарты в виртуальную машину, но они, по большей части, формата ATX, что меня не устраивает.  
  

**Материнские платы на AM5 сокете, которые поддерживают VFIO/IOMMU**

[AsRock B650M PRO RS](https://www.asrock.com/MB/AMD/B650M%20Pro%20RS/index.asp)  
[ASRock B650 LiveMixer](https://www.asrock.com/mb/AMD/B650%20LiveMixer/Specification.asp)  
[AsRock X670E Taichi](https://www.asrock.com/mb/AMD/X670E%20Taichi/index.asp)  
[AsRock B650E PG Riptide WiFi](https://pg.asrock.com/mb/AMD/B650E%20PG%20Riptide%20WiFi/index.ru.asp)  
[AsRock B650m PG Riptide](https://pg.asrock.com/mb/AMD/B650M%20PG%20Riptide/index.ru.asp)  
[AsRock B650m PG Riptide Wifi](https://pg.asrock.com/mb/AMD/B650M%20PG%20Riptide%20WIFI/index.ru.asp)  
[AsRock B650 PG Lightning](https://pg.asrock.com/mb/AMD/B650%20PG%20Lightning/index.ru.asp)  
[ASUS ProArt X670E-CREATOR WIFI](https://www.asus.com/motherboards-components/motherboards/proart/proart-x670e-creator-wifi/)  
[ASUS ROG Strix X670E-E Gaming WiFi](https://rog.asus.com/motherboards/rog-strix/rog-strix-x670e-e-gaming-wifi-model/)  
[ASUS ROG Crosshair X670E Hero](https://rog.asus.com/motherboards/rog-crosshair/rog-crosshair-x670e-hero-model/)  
[ASUS ProArt B650 Creator](https://www.asus.com/motherboards-components/motherboards/proart/proart-b650-creator/)  
[GigaByte Aorus Master X670E](https://www.gigabyte.com/Motherboard/X670E-AORUS-MASTER-rev-1x#kf)  
[Gigabyte B650i Aorus Ultra](https://www.gigabyte.com/Motherboard/B650I-AORUS-ULTRA#kf)  
[Gigabyte X670 GAMING X AX](https://www.gigabyte.ru/products/page/mb/x_670_gaming_x_ax/kf)  
[MSI MPG X670E Carbon WiFi](https://ru.msi.com/Motherboard/MPG-X670E-CARBON-WIFI)  
[MSI MPG X670E Tomahawk WiFi](https://ru.msi.com/Motherboard/MAG-X670E-TOMAHAWK-WIFI)  
  
Бонус для тех, кто читает спойлеры, дополнительная ссылка на топик: [AM5 IOMMU VFIO — Best Motherboard](https://forum.level1techs.com/t/am5-iommu-vfio-best-motherboard/189720)

  
Еще известно что в следующих материнских платах GPU Passthrough не работает/не получилось успешно завести:  
  

**Материнские платы на AM5 сокете, которые не поддерживают VFIO/IOMMU**

[AsRock B650M-HDV/M.2](https://www.asrock.com/mb/AMD/B650M-HDVM.2/index.ru.asp)  
[GIGABYTE B650M AORUS ELITE AX](https://www.gigabyte.ru/products/page/mb/B650M-AORUS-ELITE-AX-rev-1x/kf)

  
**1.1.3 Выбор материнской платы и железа.**  
Таким образом был сделан рискованный выбор, как и в 2018м году, в пользу [AsRock B650m PG Riptide](https://pg.asrock.com/mb/AMD/B650M%20PG%20Riptide/index.ru.asp) в версии без [WiFi](https://ru.wikipedia.org/wiki/Wi-Fi). Тут сыграло несколько факторов:  
  
- как и в прошлом случае c [AsRock Z390m Pro4](https://www.asrock.com/MB/Intel/Z390M%20Pro4/index.ru.asp), в сети был обнаружен успешный опыт GPU Passthrough для этой же версии материнской платы в формате ATX.
- массовый, одномоментный, завоз материнских плат [AsRock](https://www.asrock.com/index.asp) в online магазин, который специализируется в т.ч. на продаже электроники, компьютерной техники и периферии, при чем об этом я узнал через тематический форум.
- иррациональное: как определенный кредит доверия к [AsRock](https://www.asrock.com/index.asp), который производит материнские платы с богатым функционалом настроек за свои деньги. [ASUS](https://www.asus.com/) брать не хотелось, т.к. *общественная молва* с ними связывает проблемы на первых платах с завышением лимитов напряжения из коробки, о чем ниже, из-за чего [первые ПК на AM5 сокете выходили из строя буквально.](https://www.youtube.com/watch?v=Rm7iKd9AKD4)
  
**1.1.4 Общие указания к настройке [BIOS (UEFI)](https://habr.com/ru/articles/404511/) материнской платы, прежде чем запускать на ней что-либо.**  

> Для настройки параметров я использовал временный USB диск с Windows и множеством различного тестового ПО для нагрузки железа и получения его параметров, т.к. в Linux с этим проблематично.

  
Не секрет, что производители как [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80), так и плат вытягивают максимум из железа, что бы выглядеть в новостях и бенчмарках, а значит в глазах Покупателей, более весомо, из-за чего уже и на десктопе приходится заниматься понижением напряжения на [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80) в обязательном порядке. Для [AM5 сокета](https://ru.wikipedia.org/wiki/Socket_AM5) могу дать следующие рекомендации:  
  
- До установки Linux рекомендую поставить Windows: для того что бы настроить и проконтролировать температуры, потребляемую мощность/параметры питания, т.к., к сожалению, в Linux с таким софтом не густо, даже консоль не спасает.
- [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80) от [AMD](https://ru.wikipedia.org/wiki/AMD) не надо гнать руками, выставляя фиксированные напряжения/частоты. Быстрее при задании лимитов и даунвольтинг через offset, а частоты [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80) сам подберет максимальные для заданных лимитов.
- Параметр **Vcore**, принимающий в стресс-тесте/под нагрузкой значение **более 1.4В опасен для [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80)**! И, в перспективе, может привести его в негодность. Здесь правильным будет снижать его через offset при напряжении [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80) в Авто, с обязательным тестированием на стабильность в стресс-тесте. В моем случае мне пришлось снизить Vcore на 100мВ и теперь оно у меня не превышает 1.37В.
- TDP\*1.35 = PPT. То есть если хотите PPT (максимальное потребление) 105Вт, то нужно выставить PPT 105/1.35=78Вт.
- Для [ОЗУ](https://ru.wikipedia.org/wiki/%D0%9E%D0%BF%D0%B5%D1%80%D0%B0%D1%82%D0%B8%D0%B2%D0%BD%D0%B0%D1%8F_%D0%BF%D0%B0%D0%BC%D1%8F%D1%82%D1%8C) выбрать ХМР профиль на 6400МГц, следом в следующей строке установить 6000МГц.  
	  
	Проконтролировать, что бы VSoC=1.2В, CLDOVDDP=1.1В, должно получиться как у меня или на подобии:  
	  
	**Скриншот ZenTimings для ОЗУ** ![](https://habrastorage.org/r/w1560/webt/ks/yl/68/ksyl68o9gi57bivg2ihvibhqp5m.png)
	— [ОЗУ](https://ru.wikipedia.org/wiki/%D0%9E%D0%BF%D0%B5%D1%80%D0%B0%D1%82%D0%B8%D0%B2%D0%BD%D0%B0%D1%8F_%D0%BF%D0%B0%D0%BC%D1%8F%D1%82%D1%8C) рекомендую брать из списка совместимых с сайта производителя материнской платы.
- Напряжение для [ОЗУ](https://ru.wikipedia.org/wiki/%D0%9E%D0%BF%D0%B5%D1%80%D0%B0%D1%82%D0%B8%D0%B2%D0%BD%D0%B0%D1%8F_%D0%BF%D0%B0%D0%BC%D1%8F%D1%82%D1%8C) (различных VDD) для памяти не должно превышать 1.4В, во избежание неполадок.

  
По итогу промежуточного апгрейда текущий [ПК](https://ru.wikipedia.org/wiki/%D0%9F%D0%B5%D1%80%D1%81%D0%BE%D0%BD%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BA%D0%BE%D0%BC%D0%BF%D1%8C%D1%8E%D1%82%D0%B5%D1%80) принял следующий вид:  

> - Процессор — **[AMD Ryzen 9 7900X](https://www.amd.com/en/products/cpu/amd-ryzen-9-7900x)**
> - Материнская плата — **[AsRock B650m PG Riptide](https://pg.asrock.com/mb/AMD/B650M%20PG%20Riptide/index.ru.asp)**
> - ОЗУ — **[G.Skill Trident Z5 RGB 96Gb (2x48Gb) DDR5-6400 (F5-6400J3239F48GX2-TZ5RK)](https://www.gskill.com/product/165/374/1681113538/F5-6400J3239F48GX2-TZ5RK)**
> - Система охлаждения — **[Thermalright Peerless Assassin 120 PA120](https://www.thermalright.com/product/peerless-assassin-120/)**
> - Видеокарта — [INNO3D GeForce GTX 1070 iChill X4](https://youtu.be/-MpVpa34AZE)
> - RAID-контроллер — [LSI 9211-8i](https://www.ixbt.com/storage/lsi-sas9211-8i.shtml)
> - Жесткий диск — [WD Red WD40EFRX, 4Тб, HDD, SATA III, 3.5"](https://3dnews.ru/810882/page-2.html) х8
> - SSD диск — **[SSD NVMe M.2 Samsung 970 EVO Plus 1Tb](https://www.samsung.com/ru/memory-storage/nvme-ssd/970-evo-plus-1tb-mz-v7s1t0bw/)** (из наличия)
> - Блок питания — THERMALTAKE TR2 TRX-850M Bronze, 850Вт, 135мм, черный, retail
> - Корпус — [Fractal Design Node 804 черный (mATX)](https://www.fractal-design.com/products/cases/node/node-804/black/)
> - Монитор — [27" Dell UltraSharp U2713HM](https://www.displayspecifications.com/en/model/6a897)

Конечно здесь потребуется еще заменить блок питания на более мощный и видеокарту на более современную, но и в текущем виде всё работает прекрасно.  

**Кадры со сборки ПК (трафик)**

![](https://habrastorage.org/r/w1560/webt/rk/pb/h5/rkpbh5xfa_mh8eqi45neupe9wla.jpeg)  
  
![](https://habrastorage.org/r/w1560/webt/qz/sp/79/qzsp79alxur5zyke_dopah_yyzm.jpeg)  
  
![](https://habrastorage.org/r/w1560/webt/8o/os/4f/8oos4fxji9jgco_ffhwf_7yilau.jpeg)  
  
![](https://habrastorage.org/r/w1560/webt/it/xf/l5/itxfl5sv_h6rh5vbrajbjmsqxew.jpeg)

**Как итог манипуляций с питанием:**![](https://habrastorage.org/r/w1560/webt/li/f3/vu/lif3vuv-pk-hawwj54mwoaamwdu.png)

  

### 2\. Настройка Proxmox 8 для GPU Passthrough

  
При обсуждения в тематической группе в [Телеграмме](https://t.me/ru_proxmox) выяснилось, что на некотором оборудовании GPU Passthrough работает из коробки, достаточно лишь добавить видеокарту как PCI-устройство через WEB-интерфейс в настройках виртуальной машины, другим приходится настраивать с нуля и полностью. Возможно ответ кроется в выборе материнской платы или есть некий скрипт, автоматизирующий настройки [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview), но это не точно. В случае, если у Вас при добавлении устройства в свойствах виртуальной машины, проброс видеокарты в виртуальную машины автоматически не произошел, то придется настраивать ручками, как обычно. Собственно об этом ниже.  
  
В принципе здесь инструкция будет в общих чертах повторять предыдущую [мою старую статью, посвященной пробросу видеокарты на ноутбуке, при использовании Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview) 6/7 версий, за некоторыми нюансами. Но обо всём по порядку.  
  
**2.1 Что нам потребуется для установки и настройки**  
  
- [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80) и материнская плата должны поддерживать [VT-x, VT-d](https://ru.wikipedia.org/wiki/%D0%90%D0%BF%D0%BF%D0%B0%D1%80%D0%B0%D1%82%D0%BD%D0%B0%D1%8F_%D0%B2%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F) для [Intel](https://ru.wikipedia.org/wiki/Intel) или [AMD-Vi](https://ru.wikipedia.org/wiki/%D0%90%D0%BF%D0%BF%D0%B0%D1%80%D0%B0%D1%82%D0%BD%D0%B0%D1%8F_%D0%B2%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F), [IOMMU](https://ru.wikipedia.org/wiki/IOMMU) для [AMD](https://ru.wikipedia.org/wiki/AMD), а так же эти технологии необходимо активировать в BIOS до начала настройки. При этом не гарантируется, что все будет работать из коробки, из-за, возможно, плохой аппаратной реализации и отсутствия или низкого качества драйверов.
- Если будет использоваться [ноутбук](https://ru.wikipedia.org/wiki/%D0%9D%D0%BE%D1%83%D1%82%D0%B1%D1%83%D0%BA), то потребуется [ноутбук](https://ru.wikipedia.org/wiki/%D0%9D%D0%BE%D1%83%D1%82%D0%B1%D1%83%D0%BA) с дискретной игровой видеокартой, у которого схема подключения к дисплею/монитору типа MUXed/MUXless с прямым выводом на видео разъём.  
	  
	![image](https://habrastorage.org/r/w1560/getpro/habr/upload_files/ff4/413/ba8/ff4413ba8878f9db9b2a27342220c928.jpeg)
- Роутер с доступом в интернет (Для настройки и последующего использования я бы рекомендовал подключаться кабелем к роутеру).
- Физический выделенный жесткий диск [SSD](https://ru.wikipedia.org/wiki/%D0%A2%D0%B2%D0%B5%D1%80%D0%B4%D0%BE%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D1%8C) под [хост](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82) и [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) объёмом от 250Гб.
- Загрузочная USB флешка с [Proxmox'ом](https://www.proxmox.com/en/downloads) (надстройка над Debian Linux + KVM).
- Последняя версия [VirtIO драйверов](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/).
- Дополнительный внешний монитор, подключённый к Вашему ноутбуку кабелем в видео-разъем управляемым напрямую дискретной видеокартой (кроме случаев, если у Вас дисплей ноутбука напрямую подключен к дискретной видеокарте).
- Дополнительную мышь и клавиатуру для гостевой системы, по крайней мере для первоначальной настройки.
- Для удобства — второй [ПК](https://ru.wikipedia.org/wiki/%D0%9F%D0%B5%D1%80%D1%81%D0%BE%D0%BD%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BA%D0%BE%D0%BC%D0%BF%D1%8C%D1%8E%D1%82%D0%B5%D1%80) / [ноутбук](https://ru.wikipedia.org/wiki/%D0%9D%D0%BE%D1%83%D1%82%D0%B1%D1%83%D0%BA) в сети на время установки и настройки софта, категорически для Вашего удобства, но это не является необходимым условием работы и дальнейшей эксплуатации такого [ноутбука](https://ru.wikipedia.org/wiki/%D0%9D%D0%BE%D1%83%D1%82%D0%B1%D1%83%D0%BA).
  
**2.2 Установка [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview) и настройка [хоста](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82)**  
  

> **Здесь и далее нужно отметить, что рендер сайта Habr кавычки штрихом '' '' местами автоматически заменяет на кавычки елочкой «»**. Прошу Вас, учитывайте это при копировании команд из этой статьи, т.к. иначе настроить верно не удастся. Если кто-то  
> знает как обходить это ограничение в статьях при публикации, то прошу дать мне знать. Спасибо.

0-й этап. Соединяем оборудование кабелями [LAN](https://ru.wikipedia.org/wiki/%D0%9B%D0%BE%D0%BA%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%B2%D1%8B%D1%87%D0%B8%D1%81%D0%BB%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D1%81%D0%B5%D1%82%D1%8C) и присоединяем их к роутеру, для включения в [локальную сеть](https://ru.wikipedia.org/wiki/%D0%9B%D0%BE%D0%BA%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%B2%D1%8B%D1%87%D0%B8%D1%81%D0%BB%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D1%81%D0%B5%D1%82%D1%8C). Включаем, проверяем что бы в [UEFI (BIOS'е)](https://habr.com/ru/articles/404511/) на устройстве, выполняющем функции [хост](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82) для [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview), были включены нужные параметры виртуализации, указанные в требованиях к железу выше в этой статьи.  
  
1-й этап. [Устанавливаем Proxmox.](https://pve.proxmox.com/wiki/Installation) Здесь все просто, самое главное аккуратнее с IP, т.к. теперь Ваше устройство по Вами выбранному протоколу ([LAN](https://ru.wikipedia.org/wiki/%D0%9B%D0%BE%D0%BA%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%B2%D1%8B%D1%87%D0%B8%D1%81%D0%BB%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D1%81%D0%B5%D1%82%D1%8C) / [WiFi](https://ru.wikipedia.org/wiki/Wi-Fi)) будет работать на статике и именно через него виртуальные машины будут получать интернет. Не всегда это удобно, хотя потом можно будет перенастроить или даже обойти, например пробросив в виртуальную машину напрямую порт с USB — 4G модемом.  
  
После установки на [ПК](https://ru.wikipedia.org/wiki/%D0%9F%D0%B5%D1%80%D1%81%D0%BE%D0%BD%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BA%D0%BE%D0%BC%D0%BF%D1%8C%D1%8E%D1%82%D0%B5%D1%80) / [ноутбуке](https://ru.wikipedia.org/wiki/%D0%9D%D0%BE%D1%83%D1%82%D0%B1%D1%83%D0%BA) будет доступна только консоль, но в [локальной сети](https://ru.wikipedia.org/wiki/%D0%9B%D0%BE%D0%BA%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%B2%D1%8B%D1%87%D0%B8%D1%81%D0%BB%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D1%81%D0%B5%D1%82%D1%8C) [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview) будет доступен через WEB-интерфейс по адресу:  
  
```
https://"указанный_вами_при_установке_IP:8006
```
  
или, для тех случаях если Вы используете [DE](https://ru.wikipedia.org/wiki/%D0%A1%D1%80%D0%B5%D0%B4%D0%B0_%D1%80%D0%B0%D0%B1%D0%BE%D1%87%D0%B5%D0%B3%D0%BE_%D1%81%D1%82%D0%BE%D0%BB%D0%B0) на хосте:  
  
```
https://127.0.0.1:8006
https://localhost:8006
```
  
Login: root  
Password: тот\_что\_вы\_указали\_при\_установке\_Proxmox  
  
В случае если нет второго [ПК](https://ru.wikipedia.org/wiki/%D0%9F%D0%B5%D1%80%D1%81%D0%BE%D0%BD%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BA%D0%BE%D0%BC%D0%BF%D1%8C%D1%8E%D1%82%D0%B5%D1%80) / [ноутбука](https://ru.wikipedia.org/wiki/%D0%9D%D0%BE%D1%83%D1%82%D0%B1%D1%83%D0%BA), то перед дальнейшей настройкой необходимо установить графический интерфейс для Linux:  

**Ересь. Установка DE в Proxmox**

> [Proxmox в основном используется в качестве платформы виртуализации БЕЗ установки дополнительного программного обеспечения. В некоторых случаях имеет смысл иметь полный рабочий стол, работающий на Proxmox, например, для разработчиков, использующих Proxmox в качестве своей основной рабочей станции / настольного ПК.  
>   
> Установка дополнительных пакетов может привести к проблемам при обновлении гипервизора, не поддерживается службой поддержки Proxmox и, следовательно, может быть использована только экспертными Пользователями.](https://pve.proxmox.com/wiki/Developer_Workstations_with_Proxmox_VE_and_X11)

  
Для этого в консоли прописываете поочередно команды обновления репозитория:  
  

> \# apt-get update  
> \# apt-get dist-upgrade

после чего ставим выбранный GUI Linux (xfce4, gnome, kde,...) на выбор, например облегченная версия KDE:

> \# apt-get install kde-plasma-desktop plasma-nm chromium

или, например, XFCE:

> \# apt-get install xfce4 chromium lightdm

Команды для консоли по установке стандартных [DE](https://ru.wikipedia.org/wiki/%D0%A1%D1%80%D0%B5%D0%B4%D0%B0_%D1%80%D0%B0%D0%B1%D0%BE%D1%87%D0%B5%D0%B3%D0%BE_%D1%81%D1%82%D0%BE%D0%BB%D0%B0) можно найти, покопавшись в [Debian Wiki](https://wiki.debian.org/DesktopEnvironment).  
  
Перед тем как перезагрузится нужно создать юзера с обычными правами в системе, т.к. большинство [графических окружений Linux](https://ru.wikipedia.org/wiki/%D0%A1%D1%80%D0%B5%D0%B4%D0%B0_%D1%80%D0%B0%D0%B1%D0%BE%D1%87%D0%B5%D0%B3%D0%BE_%D1%81%D1%82%D0%BE%D0%BB%D0%B0) не позволят осуществить вход пользователю [root](https://ru.wikipedia.org/wiki/Root) без дополнительных танцев с бубном:  
```
# adduser новое_имя_пользователя
```
  
Добавляем нового пользователя в группу sudoers, если это Вам необходимо для работы, или игнорируем данную строку:

> \# usermod -aG sudo новое\_имя\_пользователя

  
После перезагрузки [хоста](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82), открываем браузер, вводим в строке адреса сайта адрес WEB-интерфейса [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview) (см. чуть выше по тексту), прописываем логин и пароль пользователя [root](https://ru.wikipedia.org/wiki/Root) и попадаем в:  

**меню настроек хоста гипервизора. Картинка.**![](https://habrastorage.org/r/w1560/webt/4b/h5/db/4bh5dbe53rydl19ylu0p-fgh6yw.png)

  
2-й этап. Настраиваем [хост](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82). Открываем консоль [хоста](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82) под [root](https://ru.wikipedia.org/wiki/Root) 'ом. Для этого в браузере выбираем слева название Вашего [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview) сервера, данное Вами при установке, и кликнув на нем правой кнопкой мыши, выбираем в выпадающем меню Shell. Либо выполняем команды непосредственно в текстовом терминале сервера на [хосте](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82).  
  
```
# nano /etc/default/grub
```
  
и редактируем строку, заменив в ней значения на следующие:  
  
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"
```
  
Если у Вас [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80) от [AMD](https://ru.wikipedia.org/wiki/AMD), то в строке выше `intel_iommu=on` меняете на `amd_iommu=on`, либо полностью опускаете этот аргумент, т.к. он теперь не является обязательным. А вот `iommu=pt` я рекомендую прописывать во всех случаях. Включение этого режима может повысить производительность. Это связано с тем, что виртуальные машины передадут запросы [DMA](https://ru.wikipedia.org/wiki/%D0%9F%D1%80%D1%8F%D0%BC%D0%BE%D0%B9_%D0%B4%D0%BE%D1%81%D1%82%D1%83%D0%BF_%D0%BA_%D0%BF%D0%B0%D0%BC%D1%8F%D1%82%D0%B8) непосредственно в аппаратный [IOMMU](https://ru.wikipedia.org/wiki/IOMMU).  
  
После этой манипуляции необходимо сохранить файл (Ctrl+O, затем Enter), выйти из редактора nano в консоль (Ctrl+X) и дать команду, с последующей командой на перезагрузку [хоста](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82) (если у Вас в это время крутятся параллельно несколько [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0), то перезагрузку стоит осуществлять после выключения таких [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) вручную через WEB-интерфейс):  
```
# update-grub
# reboot now
```
  
Если все сделано правильно, и оборудование поддерживает верные настройки, то [скрипт из ArchWiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)  
  
```
# for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
```
Покажет нам вот такую красоту:  

**После обновления BIOS с 1.24 на 2.06.AS03\[Beta\] картина по IOMMU группам резко стала лучше**

> IOMMU Group 0:  
> 00:01.0 Host bridge \[0600\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14da\]  
> IOMMU Group 1:  
> 00:01.1 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14db\]  
> IOMMU Group 2:  
> 00:01.2 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14db\]  
> IOMMU Group 3:  
> 00:02.0 Host bridge \[0600\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14da\]  
> IOMMU Group 4:  
> 00:02.1 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14db\]  
> IOMMU Group 5:  
> 00:03.0 Host bridge \[0600\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14da\]  
> IOMMU Group 6:  
> 00:04.0 Host bridge \[0600\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14da\]  
> IOMMU Group 7:  
> 00:08.0 Host bridge \[0600\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14da\]  
> IOMMU Group 8:  
> 00:08.1 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14dd\]  
> IOMMU Group 9:  
> 00:08.3 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14dd\]  
> IOMMU Group 10:  
> 00:14.0 SMBus \[0c05\]: Advanced Micro Devices, Inc. \[AMD\] FCH SMBus Controller \[1022:790b\] (rev 71)  
> 00:14.3 ISA bridge \[0601\]: Advanced Micro Devices, Inc. \[AMD\] FCH LPC Bridge \[1022:790e\] (rev 51)  
> IOMMU Group 11:  
> 00:18.0 Host bridge \[0600\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14e0\]  
> 00:18.1 Host bridge \[0600\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14e1\]  
> 00:18.2 Host bridge \[0600\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14e2\]  
> 00:18.3 Host bridge \[0600\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14e3\]  
> 00:18.4 Host bridge \[0600\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14e4\]  
> 00:18.5 Host bridge \[0600\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14e5\]  
> 00:18.6 Host bridge \[0600\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14e6\]  
> 00:18.7 Host bridge \[0600\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:14e7\]  
> IOMMU Group 12:  
> 01:00.0 VGA compatible controller \[0300\]: NVIDIA Corporation GP104 \[GeForce GTX 1070\] \[10de:1b81\] (rev a1)  
> 01:00.1 Audio device \[0403\]: NVIDIA Corporation GP104 High Definition Audio Controller \[10de:10f0\] (rev a1)  
> IOMMU Group 13:  
> 02:00.0 Serial Attached SCSI controller \[0107\]: Broadcom / LSI SAS2008 PCI-Express Fusion-MPT SAS-2 \[Falcon\] \[1000:0072\] (rev 03)  
> IOMMU Group 14:  
> 03:00.0 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:43f4\] (rev 01)  
> IOMMU Group 15:  
> 04:00.0 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:43f5\] (rev 01)  
> IOMMU Group 16:  
> 04:01.0 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:43f5\] (rev 01)  
> IOMMU Group 17:  
> 04:02.0 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:43f5\] (rev 01)  
> IOMMU Group 18:  
> 04:03.0 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:43f5\] (rev 01)  
> 08:00.0 Ethernet controller \[0200\]: Realtek Semiconductor Co., Ltd. RTL8125 2.5GbE Controller \[10ec:8125\] (rev 05)  
> IOMMU Group 19:  
> 04:04.0 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:43f5\] (rev 01)  
> IOMMU Group 20:  
> 04:05.0 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:43f5\] (rev 01)  
> IOMMU Group 21:  
> 04:06.0 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:43f5\] (rev 01)  
> IOMMU Group 22:  
> 04:08.0 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:43f5\] (rev 01)  
> 0c:00.0 Non-Volatile memory controller \[0108\]: Samsung Electronics Co Ltd NVMe SSD Controller SM981/PM981/PM983 \[144d:a808\]  
> IOMMU Group 23:  
> 04:0c.0 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:43f5\] (rev 01)  
> 0d:00.0 USB controller \[0c03\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:43f7\] (rev 01)  
> IOMMU Group 24:  
> 04:0d.0 PCI bridge \[0604\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:43f5\] (rev 01)  
> 0e:00.0 SATA controller \[0106\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:43f6\] (rev 01)  
> IOMMU Group 25:  
> 0f:00.0 VGA compatible controller \[0300\]: Advanced Micro Devices, Inc. \[AMD/ATI\] Raphael \[1002:164e\] (rev c2)  
> IOMMU Group 26:  
> 0f:00.1 Audio device \[0403\]: Advanced Micro Devices, Inc. \[AMD/ATI\] Rembrandt Radeon High Definition Audio Controller \[1002:1640\]  
> IOMMU Group 27:  
> 0f:00.2 Encryption controller \[1080\]: Advanced Micro Devices, Inc. \[AMD\] VanGogh PSP/CCP \[1022:1649\]  
> IOMMU Group 28:  
> 0f:00.3 USB controller \[0c03\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:15b6\]  
> IOMMU Group 29:  
> 0f:00.4 USB controller \[0c03\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:15b7\]  
> IOMMU Group 30:  
> 0f:00.6 Audio device \[0403\]: Advanced Micro Devices, Inc. \[AMD\] Family 17h/19h HD Audio Controller \[1022:15e3\]  
> IOMMU Group 31:  
> 10:00.0 USB controller \[0c03\]: Advanced Micro Devices, Inc. \[AMD\] Device \[1022:15b8\]

Здесь надо отметить, что: если распределение оборудования по [IOMMU](https://ru.wikipedia.org/wiki/IOMMU) группам у Вас плохое, то нужно пытаться решить эту проблему с обновления прошивки [UEFI (BIOS)](https://habr.com/ru/articles/404511/) для Вашей материнской платы.  
  
Далее прописываем в консоли следующие команды, которые отвечают за уменьшение проблем с работой пробрасываемого железа в виртуальную машину.  
  
```
# echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf
# echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf
```
  
Прописываем в файле конфигурации `# nano /etc/modules` загрузку необходимых драйверов (упоминание vfio\_virqfd не обязательно, т.к., начиная с ядра Linux версии 6.2 и старше, теперь он включен автоматически):  
  
```
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
```
  
Сохраняем файл и выходим. Затем запрещаем [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview) 'у использовать следующие драйвера видеокарт на [хосте](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82), в зависимости от того какую видеокарту Вы пробрасываете в [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0):  
  
AMD GPUs  
  
```
# echo "blacklist amdgpu" >> /etc/modprobe.d/blacklist.conf
# echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf
```
  
NVIDIA GPUs  
  
```
# echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf 
# echo "blacklist nvidia*" >> /etc/modprobe.d/blacklist.conf
```
  
Intel GPUs  
  
```
# echo "blacklist i915" >> /etc/modprobe.d/blacklist.conf
```
  
Прописываем следующую команду (здесь 01:00 блок адресов дискретной ВК, что бы уточнить Ваш случай, то необходимо дать команду `# lspci`)  
  
```
# lspci -n -s 01:00
```
  
на что получаем ответ навроде этого:  
  
`01:00.0 0300: 10de:1b81 (rev a2)   01:00.1 0403: 10de:10f0 (rev a1)`  
  
Запоминаем эти значения, после чего создаем/открываем для редактирования файл настроек `# nano /etc/modprobe.d/vfio.conf` и аккуратно прописываем:  
  
```
options vfio-pci ids=10de:1b81,10de:10f0 disable_vga=1
```
  
На этом настройка самого [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview) у нас закончена, необходимо дать следующие команды, (если у Вас в это время крутятся параллельно несколько [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0), то перезагрузку стоит осуществлять после выключения таких [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) вручную через WEB-интерфейс):  
  
```
# update-initramfs -u -k all
# reboot now
```
  
3-й этап. Настраиваем виртуальную машину. Теперь из WEB-интерфейса через браузер создаем и настраиваем виртуальную машину, в дальнейшем, для более тонкой работы с файлом конфигурации [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0), можно будет работать через текстовый редактор из консоли `# nano /etc/pve/qemu-server/номер_виртуальной_машины_из_WEB-интерфейса.conf`. Здесь нужно отметить следующее:  
  
- args:, добавляется при работе через текстовый редактор. Стоит помнить, что сколько бы ни было параметров, они должны быть в одной строке args:.
- cpu: host, если Вы планируете играть в игры на [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) или работать. При этом cores это потоки [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80). Сколько бы Вы их ни отдали [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0), необходимо что-то оставить [хосту](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82), хотя бы парочку cores, превышать лимит физических потоков Вашего [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80) не рекомендуется, т.к. иначе виртуальная машина просто не запустится.
- sockets: 1, всегда, если Вы не знаете зачем Вам больше и как это работает.
- bios: ovmf, и никакой другой, если Вы планируется GPU Passthrough. Если [гость](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) на Linux'е, не поленитесь, при запуске виртуальной машины зажмите F2 и уберите крестик с опции **Secure boot**.
- machine: q35, без вариантов
- scsihw: virtio-scsi-single, что бы установщик [гостя](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) на Windows увидел виртуальный диск, то не поленитесь подсунуть ему [iso образ VirtIO с драйверами](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/), а позже не поленитесь установить полный пакет гостевых дополнений в системе. Рекомендую использовать именно virtio scsi single, т.к. получается отдельный контроллер на каждый диск. Соответственно все виртуальные диски оформлять как SCSI. Если для хранения данных [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) у Вас используется [SSD](https://ru.wikipedia.org/wiki/%D0%A2%D0%B2%D0%B5%D1%80%D0%B4%D0%BE%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D1%8C), то обязательно при конфигурации диска добавлять опции «discard» и «ssd emulation».  
	  
	![](https://habrastorage.org/r/w1560/webt/x0/rg/dd/x0rgddvuuayiyy86pw36jjdy2zg.png)
- balloon: 0, если [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) на Windows, т.к. при значение 1 начинает грузить [ЦП](https://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D0%BD%D1%82%D1%80%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81%D0%BE%D1%80), но при этом экономит [ОЗУ](https://ru.wikipedia.org/wiki/%D0%9E%D0%BF%D0%B5%D1%80%D0%B0%D1%82%D0%B8%D0%B2%D0%BD%D0%B0%D1%8F_%D0%BF%D0%B0%D0%BC%D1%8F%D1%82%D1%8C), потребляя ее в динамическом режиме. Если выключить, то [хост](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82) резервирует за виртуальной машиной указанный в настройках полный объем [ОЗУ](https://ru.wikipedia.org/wiki/%D0%9E%D0%BF%D0%B5%D1%80%D0%B0%D1%82%D0%B8%D0%B2%D0%BD%D0%B0%D1%8F_%D0%BF%D0%B0%D0%BC%D1%8F%D1%82%D1%8C). У [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) на Linux такой проблемы нет — можно смело пользоваться.
- vga: none, и только так. Картинку с видеокарты снимать напрямую видеокабелем HDMI/DP/DVI/VGA, подключаемым в нее.
  
[Nvidia с апреля 2021 года на игровых видеокартах не блокирует проброс своего оборудования в виртуальную машину](https://nvidia.custhelp.com/app/answers/detail/a_id/5173/~/geforce-gpu-passthrough-for-windows-virtual-machine-%28beta%29).  
  
Соответственно прописывание аргументов в настройках более не требуется, если же кто-то столкнется на старой версии драйверов, то текст в настройках конфигурационного файл следующий:  
  
```
args: -cpu 'host,+kvm_pv_unhalt,+kvm_pv_eoi,hv_vendor_id=NV43FIX,kvm=off'
```
  
В общем по итогу этих манипуляций у Вас получится что-то навроде этого:  

**Файл настроек виртуальной машины для ПК в статье**

```
agent: 1,fstrim_cloned_disks=1
balloon: 0
bios: ovmf
boot: order=scsi0;ide0
cores: 12
cpu: host
efidisk0: local-lvm:vm-210-disk-0,efitype=4m,pre-enrolled-keys=1,size=4M
hostpci0: 0000:01:00,pcie=1,x-vga=1
hostpci1: 0000:0f:00.4
ide0: local:iso/virtio-win-0.1.225.iso,media=cdrom,size=519590K
machine: pc-q35-7.2
memory: 32768
meta: creation-qemu=7.1.0,ctime=1672658056
name: Windows
net0: virtio=12:C2:C1:CC:FC:15,bridge=vmbr0
numa: 0
ostype: win10
scsi0: local-lvm:vm-210-disk-1,discard=on,size=80G,ssd=1
scsihw: virtio-scsi-single
smbios1: uuid=2af35573-b8d8-4c14-ac31-4a91253ec752
sockets: 1
vga: none
vmgenid: 45a1294f-b135-9aad-890e-50fc513cc120
```
  

  
Здесь нужно сказать следующее: Если Ваше железо приняло все текущие настройки на ура, то при старте [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) с подключенным монитором в видеопорт дискретной видеокарты вы увидите картинку с логотипом [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview) на заставке. Дальше следуют 3 пути развития событий:  
  
— Идеальный — весь процесс установки ОС вы будете наблюдать на внешнем мониторе. Тогда тормозим систему, пробрасываем USB мышь и временно USB клавиатуру. После чего вновь стартуем [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) и проводим установку до конца.  
  
— Дальше логотипа [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview) ситуация не сдвинется с места, не смотря на то, что если все-таки подключить софтовую видеокарту и подключится к виртуальной машине через консоль VNC в браузере через WEB-интерфейс, то процессом установки ОС можно будет управлять дальше. В этот момент нужно остановиться и проверить настройки [хоста](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82) [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview). Возможно потребуется дополнительно прописать параметры в файле grub/конфигурационных файлах в каталоге /etc/modprobe.d. Т.к. если видеосигнал пошел, то и проброс возможен. А может быть проблема просто в с том, что Вы забыли в конфигурации [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) выключить софтовую видеокарту `vga: none`  
  
— Черный дисплей и отсутствие видеосигнала на внешнем мониторе. Скорее всего вы потерпели фиаско и, если проблема не в отсутствии контакта, неверных настройках, забытом переключателе питания или канале видео вывода на мониторе, то — увы!  
  

### 3\. Выжимки и небольшие инструкции из первых трех статей

  
**3.1 Проброс других PCI-e устройств в виртуальную машину.**  
  
Для того что бы пробросить такое устройство, не видеокарту, достаточно что бы Ваше железо поддерживало [VT-x, VT-d](https://ru.wikipedia.org/wiki/%D0%90%D0%BF%D0%BF%D0%B0%D1%80%D0%B0%D1%82%D0%BD%D0%B0%D1%8F_%D0%B2%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F) от [Intel](https://ru.wikipedia.org/wiki/Intel) или [AMD-Vi](https://ru.wikipedia.org/wiki/%D0%90%D0%BF%D0%BF%D0%B0%D1%80%D0%B0%D1%82%D0%BD%D0%B0%D1%8F_%D0%B2%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F), [IOMMU](https://ru.wikipedia.org/wiki/IOMMU) от [AMD](https://ru.wikipedia.org/wiki/AMD), а так же через grub эта опция была включена в системе, см.описание выше. Если интересующее Вас устройство изолировано в отдельной [IOMMU](https://ru.wikipedia.org/wiki/IOMMU) группе, то, как правило, такое устройство может быть проброшено в [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0). Для того что бы определить адрес интересующего Вас устройства, обычно, достаточно дать команду в консоли [хоста](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82) `# lspci` и изучить листинг вывода, после чего через WEB-интерфейс добавить такое устройство:  
  
![](https://habrastorage.org/r/w1560/webt/vl/br/ka/vlbrkalmjwtmsbdz-i-jeuq_me4.png)  
**3.2 Добавляем локальный [SATA](https://ru.wikipedia.org/wiki/SATA) диск в [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0)**  
  
Такие [HDD](https://ru.wikipedia.org/wiki/%D0%96%D1%91%D1%81%D1%82%D0%BA%D0%B8%D0%B9_%D0%B4%D0%B8%D1%81%D0%BA) / [SSD](https://ru.wikipedia.org/wiki/%D0%A2%D0%B2%D0%B5%D1%80%D0%B4%D0%BE%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D1%8C) можно пробрасывать как через проброс контроллера как PCIe устройство по методу указанному в статье (не рекомендую пробрасывать контроллер интегрированный в материнскую плату, только подключенные к PCIe), либо напрямую:  
  
заходим в каталог `# cd /dev/disk/by-id`, через команду `# dir` или `# ls` смотрим листинг… копируем строки вида ata-WDC\_WD40EFRX-68WT0N6\_WD-WCC4E1АС9SХ9, в которой прописан интерфейс подключения, марка и номер серии жесткого диска. Затем открываем файл конфигурации [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) `# nano /etc/pve/qemu-server/номер_виртуальной_машины_из_WEB-интерфейса.conf` и пишем:  
  
```
sata1: volume=/dev/disk/by-id/ata-WDC_WD40EFRX-68WT0N6_WD-WCC4E1АС9SХ9
```
  
и при следующем старте все работает, при этом учитывайте, что sata0-sata5, т.е. для одной [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) число подключаемых таким образом дисков, включая виртуальных, не может превышать 6 шт.  
  
**3.3 Как прокинуть в [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) клавиатуру с порта PS/2:**  
  
Сперва вводим команду в консоли `# dmesg | grep input`, затем ищем в тексте запись навроде  
  
```
…
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input<b>2</b>
…
```
  
Запоминаем цифру **2** в конце, она может быть в Вашем случае и другой. Потом в файле настроек [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) в строку добавляем `# nano /etc/pve/qemu-server/номер_виртуальной_машины_из_WEB-интерфейса.conf`:  
  
```
args: -object 'input-linux,id=kbd,evdev=/dev/input/event2,grab_all=on,repeat=on'
```
  
вставляя **2** в конец evdev=/dev/input/event **2**  
  
Для PS/2 мыши и тачпада на [ноутбуке](https://ru.wikipedia.org/wiki/%D0%9D%D0%BE%D1%83%D1%82%D0%B1%D1%83%D0%BA) — аналогично!  
  
**3.4 По USB:**  
  
Что касается USB устройств там все проще, устройства прокидываются прямо из веб формы по ID или же целиком можно прокинуть порт. Однако есть нюанс — если Вы по каким-либо причинам не можете, как и я, прокинуть аудиоустройство в [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0), т.к. оно содержится в группе с ключевыми контроллерами без которых [хост](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82) не может полноценно работать, то проброс порта/устройства через USB решает эту проблему, но звук может начать отваливаться через некоторое время работы, шипеть/гудеть и прочие… прочее, в то же время на нативной системе все будет замечательно. В этом случае необходимо пробрасывать не порт/устройство, а сам контроллер USB как PCIe устройство по методу указанному в статье. И все резко наладится. Но в то же время через [хост](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82), после запуска [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0), с такими настройками пробросить другие устройства с этого контроллера больше не получится.  
  
Еще момент, в некоторых случаях USB-токены могут содержать не только ключ, но и сопутствующую flash память, например ключи [Guardan c flash-памятью](https://www.guardant.ru/company/press-center/news/318/). Соответственно они для системы видны как малый хаб и необходимо добавлять 2 устройства, через веб интерфейс, вместо одного.  
  
**3.5 Тестирование и сравнение производительности нативной системы с [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0).**  
  
С этой темой я разбирался в прошлом году, по результатам простых тестов была написана статья, которую рекомендую к прочтению:[Есть ли жизнь в виртуалке на ПК?](https://habr.com/ru/articles/743756/) Если коротко, то основной вывод — для работы и игр накладные расходы на виртуализацию (потери производительности) сравнительно небольшие, в офисных/игровых/инженерных задачах, что бы это мешало работе.  
  
**3.6 [SSD](https://ru.wikipedia.org/wiki/%D0%A2%D0%B2%D0%B5%D1%80%D0%B4%D0%BE%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D1%8C) и [trim](https://ru.wikipedia.org/wiki/Trim_\(%D0%BA%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4%D0%B0_%D0%B4%D0%BB%D1%8F_%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D0%B5%D0%B9\)). Личное мнение и опыт:**  
  
Больная тема для виртуализации. Для того что бы дать эту команду для всех смонтированных дисков/разделов [SSD](https://ru.wikipedia.org/wiki/%D0%A2%D0%B2%D0%B5%D1%80%D0%B4%D0%BE%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D1%8C) на [хосте](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82), то достаточно в консоли команду `# fstrim -av`, однако к этому нужно добавить, что если у Вас по умолчанию разделы [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) находятся на [LVM](https://ru.wikipedia.org/wiki/LVM), то для них эта команда эта не сработает. Что бы на таких томах/областях диска заработал [trim](https://ru.wikipedia.org/wiki/Trim_\(%D0%BA%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4%D0%B0_%D0%B4%D0%BB%D1%8F_%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D0%B5%D0%B9\)) необходимо отредактировать файл настроек [LVM](https://ru.wikipedia.org/wiki/LVM) `# nano /etc/lvm/lvm.conf`, для чего в строке необходимо перед переменной убрать комментирующий символ # и приравнять ее значение к 1. После сохранить файл, выйти из него и перезагрузить [хост](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82). Тогда осуществлять [trim](https://ru.wikipedia.org/wiki/Trim_\(%D0%BA%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4%D0%B0_%D0%B4%D0%BB%D1%8F_%D0%BD%D0%B0%D0%BA%D0%BE%D0%BF%D0%B8%D1%82%D0%B5%D0%BB%D0%B5%D0%B9\)) таких областей, в которых хранятся данные [гостевых](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) виртуальных машин на [хосте](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82), можно будет из самих виртуальных машин.  
  
```
...
issue_discards = 1
...
```
  
Более подробно можно прочитать в статье [Активация discard (TRIM) на Linux для SSD](https://habr.com/ru/articles/497004/)  
  
**3.8 Основной гайд по настройке PCI Passthrough и GPU Passthrough переместился из [Proxmox Wiki](https://pve.proxmox.com/wiki/PCI_Passthrough) в [документацию.](https://pve.proxmox.com/pve-docs/chapter-qm.html#_host_device_passthrough)**  
  
**3.9 Проблема установить драйвер для видеокарт Nvidia для Debian Linux 12**  
  
Периодически проблема всплывает в тематических чатах, не буду говорить за всех, но, будете смеяться, мне помогло следующее: Проблемы в linux-headers, точнее в том что заголовки к ядру нужно установить вручную, т.к. почему-то этот пакет не идет «из коробки».  
  
Дело было так: я проверил выключенный secure boot, обновил установленную систему, установил последний драйвер Nvidia из репозитория, на initramfs ядро высыпало множество предупреждений в консоли, и тут меня осенило, без перезагрузки, нашел к своему ядру linux-headers пакет и тупо его установил, в процессе установки тот переустановил текущее ядро и перепрописал NV\_VERBOSE=1.  
  

**После перезагрузки все завелось** ![](https://habrastorage.org/r/w1560/webt/jy/p5/xf/jyp5xfto2ek51hs6wc5ssxnbzva.png)

  
**3.10 По выбору видеокарты для GPU Passthrough**  
  
**3.10.1** AMD RADEON 5xxx, 6xxx, 7xxx, NVIDIA GeForce 7, 8, GTX 4xx, 5xx, 6xx, 7xx, 9xx, 10xx, 15xx, 16xx и RTX 20xx были отмечены как работающие. Более новые тоже должны работать без проблем.  
  
**3.10.2** AMD Navi (5xxx (XT) / 6xxx (XT)) страдает от ошибки сброса (см. [github.com/gnif/vendor-reset](https://github.com/gnif/vendor-reset)), хотя пользователям удалось заставить их работать, они требуют гораздо больше усилий и, вероятно, не будут работать полностью стабильно (см. [Специфические проблемы AMD](https://pve.proxmox.com/wiki/PCI_Passthrough#AMD_specific_issues) и пути их обхода). AMD Navi 7xxx (XT) скорее не пробрасываются, чем пробрасывают из-за проблем реализации/работы [FLR (Function-level reset)](https://docs.amd.com/r/3.3-English/pg347-cpm-dma-bridge/Function-Level-Reset?tocId=5U5WgyT2qi~zyqqMvEvwdQ).  
  
**3.10.3** Возможно, вам придется загрузить некоторые конкретные параметры в grub.cfg или другие значения настройки конфигурационных файлов для ядра Linux (по пути в /etc/modprobe.d), чтобы ваша конфигурация работала стабильно.  
  
**3.10.4** [Хорошая тема](https://bbs.archlinux.org/viewtopic.php?id=162768) с форума Arch Linux  
  
**3.10.5** В случае проблем обязательно убедитесь что хост не использует драйвер видеокарты. Так же зачастую выручает перемещение карты в другой слот или включить / отключить [legacy boot support](https://qna.habr.com/q/325907) в [BIOS (UEFI)](https://habr.com/ru/articles/404511/) [хоста](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82).  
  
**3.11 При пробросе видеокарты в [госте](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) на Linux, если в роли [хоста](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82) выступает [ноутбук](https://ru.wikipedia.org/wiki/%D0%9D%D0%BE%D1%83%D1%82%D0%B1%D1%83%D0%BA),** полезно будет добавить в grub опцию `pcie_aspm=off`

> С помощью технологии [ASPM (Active-State Power Management)](https://linuxshare.ru/docs/distro/redhat/el6/Power_Management_Guide/ASPM.html) можно эффективно управлять потреблением энергии шин PCI Express (PCIe, Peripheral Component Interconnect Express) посредством их перевода в энергосберегающий режим, если подключенные через них устройства не используются. ASPM контролирует обе точки подключения и позволяет снизить потребление энергии, даже если подключенное устройство находится в рабочем режиме. При активации ASPM задержка ответа устройства увеличивается из-за времени, затрачиваемого на переключение режимов шины.

  
**3.12 Ограничения метода описанного в статье.**  
В каждый момент времени на хосте может быть проброшено только одно устройство/видеокарта, по методу указанному в статье. Однако ничто не мешает Вам создать несколько [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) с такими настройками и запускать их поочередно. Бэкап «на горячую» таких [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) тоже невозможен, т.к. у [хоста](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82) нет доступа к памяти видеокарты в момент работы.  
  
**3.1415926535 [Proxmox](https://www.proxmox.com/en/proxmox-virtual-environment/overview), в настоящее время, использует один из двух загрузчиков, в зависимости от настроек диска, выбранных в установщике.**  
Для систем EFI, установленных с [ZFS](https://ru.wikipedia.org/wiki/ZFS) в качестве корневой файловой системы, используется [systemd-boot](https://pve.proxmox.com/wiki/Host_Bootloader#sysboot_systemd_boot), если не включена опция Secure Boot. Во всех других развертываниях используется стандартный загрузчик GRUB (обычно это относится и к системам, установленным поверх Debian).  
  
В этом случае параметры для ядра системы (”intel\_iommu=on iommu=pt”/”amd\_iommu=on iommu=pt”), активирующие включение в системе работу опции [IOMMU](https://ru.wikipedia.org/wiki/IOMMU), нужно будет размещать не в конфигурационном файле grub, а в файле `# nano /etc/kernel/cmdline`. Применение настроек вызывается командой `proxmox-boot-tool refresh` с последующей перезагрузкой системы. Далее настройки ничем не отличаются от написанных в статье.  
  
Более подробно о настройке [systemd-boot здесь](https://pve.proxmox.com/wiki/Host_Bootloader#sysboot_systemd_boot) и [здесь](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#sysboot)  
  
**P.S.**  
  
Бонусные материалы от автора статьи:  
  
- [Есть ли жизнь в виртуалке на ПК?](https://habr.com/ru/articles/743756/) (простые тесты производительности [ВМ](https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F_%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D0%B0) и [хоста](https://ru.wikipedia.org/wiki/%D0%A5%D0%BE%D1%81%D1%82) в обыденных задачах пользователя)
- [PCI Passthrough. Proxmox Wiki (актуальная редакция)](https://pve.proxmox.com/wiki/PCI_Passthrough)

Что мешает тебе в работе?

Бу! Испугались?

Road to Highload

Годнота из блогов компаний

На мороз!