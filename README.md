На основе документа "SPI Block Guide V04.01" был сформирован и описан минимальный набор модулей для примитивного ядра интерфейса SPI. Также модули промоделированы и отлажены в ПЛИС Intel Cyclone IV.

Структура ядра:
![SPI](https://github.com/TurDi1/Primitive_SPI/assets/90939428/5ad93f05-98d8-4bf1-a56c-c6c22f521a09)

Ядро интерфейса состоит из:
* Генератора синхросигнала приема-передачи (baud_rate_generator).
* Модуля управления фазой и полярностью приема-передачи (ppc).
* FIFO для хранения отправляемых и принятых данных.
* Модуля управления приемо-передачей байтов через интерфейс.



Ниже представлены диаграммы RTL-моделирования некоторых модулей:
* baud_rate_generator
  ![BAUD_GENERATOR_MODLESIM](https://github.com/TurDi1/Primitive_SPI/assets/90939428/4a9e778d-3b9d-4a51-8a1d-8e9928fd3136)
* ppc
  ![PPC_MODLESIM](https://github.com/TurDi1/Primitive_SPI/assets/90939428/d10dff93-265e-4db7-877b-216158f4d87f)
* Модуля ядра в целом. Отправка тестовой последовательности байт интерфейсу самому себе.
  ![DUT_MODELSIM_1](https://github.com/TurDi1/Primitive_SPI/assets/90939428/0a3cb334-6a0f-449c-8e5e-96fef371d144)
  ![DUT_MODELSIM](https://github.com/TurDi1/Primitive_SPI/assets/90939428/aa02d2b5-d9dd-4f1b-80e2-2f96ae6b2a78)

Также сняты диаграммы из логического анализатора ПЛИС SignalTapII с результатом работы ядра. На первой диаграмме показана отправка тестовой последовательности байт интерфейсу самому себе. На второй диаграмме показана отправка инструкции JEDEC ID (0x9f) во flash Winbond 25Q32 и прием трех байт из нее.
![SIgnalTAPII_HW_CHECK_SELFTEST](https://github.com/TurDi1/Primitive_SPI/assets/90939428/8bd27f96-01d9-4a0a-8ff8-edb2fc58a5c1)

![SIgnalTAPII_HW_CHECK](https://github.com/TurDi1/Primitive_SPI/assets/90939428/4ae03074-627c-40a8-97b3-d07d587394e3)
