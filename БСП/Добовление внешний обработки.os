#use "updater1c"

// ****************************************************************************
// Переменные модуля
// ****************************************************************************

Перем errors;		// Признак того, что при выполнении скрипта были ошибки.
Перем updater;		// Обновлятор, через который мы получаем информацию о базе,
					// а также вызываем различные функции обновлятора.
Перем connector;	// Коннектор для подключения к базе.
Перем v8;			// Само подключение к базе через коннектор.

// ****************************************************************************
// Ваш код для выполнения обновлятором
// ****************************************************************************

Процедура Главная()

	// Обязательно прочтите статью про COM-объекты
	// http://helpme1s.ru/ispolzovanie-com-obektov-v-onescript



	//НАЧАЛО СКРИПТА ПО ДОБАВЛЕНИЮ ВНЕШНЕГО ОТЧЕТА/ОБРАБОТКИ
	ИмяФайла = "C:\1.epf"; //Укажите имя файла
	
	//Остальной код не меняется...
	
	Ф = v8.NewObject("Файл", ИмяФайла);
	РасширениеФайла = ВРег(Прав(ИмяФайла, 3));    

	
	ДД = v8.NewObject("ДвоичныеДанные", ИмяФайла);
	ХранилищеФайла = v8.NewObject("ХранилищеЗначения", ДД);            
	

	//Параметры структуры взяты из ДополнительныеОтчетыИОбработки.ФормаЭлемента
	ПараметрыРегистрации = v8.NewObject("Структура", "ИмяФайла, ОтключатьПубликацию, ОтключатьКонфликтующие, ЭтоОтчет", Ф.Имя, ложь, ложь, ложь);
	Если РасширениеФайла = "ERF" Тогда
		ПараметрыРегистрации.ЭтоОтчет = Истина;
	ИначеЕсли РасширениеФайла = "EPF" Тогда
		ПараметрыРегистрации.ЭтоОтчет = Ложь;
	Иначе
		ВызватьИсключение "Неизвестное расширение файла: " + РасширениеФайла;
	КонецЕсли;
	ПараметрыРегистрации.Вставить("АдресДанныхОбработки", v8.ПоместитьВоВременноеХранилище(ДД));
	
	//Служебный элемент для получения данных
	ООТест = v8.Справочники.ДополнительныеОтчетыИОбработки.СоздатьЭлемент();                         
	РезультатРегистрации = v8.ДополнительныеОтчетыИОбработки.ЗарегистрироватьОбработку(ООТест, ПараметрыРегистрации);          
	Если НЕ РезультатРегистрации.Успех Тогда   
		ВызватьИсключение "Не удалось зарегистрировать обработку из файла: " + РезультатРегистрации.ТекстОшибки;
	КонецЕсли;
	ИмяОбъекта = РезультатРегистрации.ИмяОбъекта;                              
	З = v8.NewObject("Запрос", 
	"ВЫБРАТЬ
	|	Т.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ДополнительныеОтчетыИОбработки КАК Т
	|ГДЕ
	|	Т.ИмяОбъекта = &ИмяОбъекта
	|	И Т.Публикация = ЗНАЧЕНИЕ(Перечисление.ВариантыПубликацииДополнительныхОтчетовИОбработок.Используется)");
	З.УстановитьПараметр("ИмяОбъекта", ИмяОбъекта);
	Выборка = З.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		ОО = Выборка.Ссылка.ПолучитьОбъект();
	Иначе             
		ОО = v8.Справочники.ДополнительныеОтчетыИОбработки.СоздатьЭлемент();                         
	КонецЕсли;

	РезультатРегистрации = v8.ДополнительныеОтчетыИОбработки.ЗарегистрироватьОбработку(ОО, ПараметрыРегистрации);          
	Если НЕ РезультатРегистрации.Успех Тогда   
		ВызватьИсключение "Не удалось зарегистрировать обработку из файла: " + РезультатРегистрации.ТекстОшибки;
	КонецЕсли;
	ОО.Публикация = v8.Перечисления.ВариантыПубликацииДополнительныхОтчетовИОбработок.Используется;
	ОО.ХранилищеОбработки = ХранилищеФайла;
	ОО.Записать();

	//КОНЕЦ СКРИПТА ПО ДОБАВЛЕНИЮ ВНЕШНЕГО ОТЧЕТА/ОБРАБОТКИ




КонецПроцедуры


// ****************************************************************************
// Служебные процедуры
// ****************************************************************************

Процедура ПриНачалеРаботы()

	errors = Ложь;

	updater = Новый Updater1C;

	// Если в скрипте не планируется использовать
	// подключение к базе - просто закомментируйте
	// две нижние строки.
	connector = updater.CreateConnector();
	v8 = updater.BaseConnectNew(connector);
	
КонецПроцедуры

Процедура ПриОкончанииРаботы()

	Если v8 <> Неопределено Тогда
		Попытка
			ОсвободитьОбъект(v8);
			v8 = Неопределено;
		Исключение
		КонецПопытки;
	КонецЕсли;
	
	Если connector <> Неопределено Тогда
		Попытка
			ОсвободитьОбъект(connector);
			connector = Неопределено;
		Исключение
		КонецПопытки;
	КонецЕсли;
	
	Если updater <> Неопределено Тогда
		Попытка
			ОсвободитьОбъект(updater);
			updater = Неопределено;
		Исключение
		КонецПопытки;
	КонецЕсли;

	Если errors Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;

КонецПроцедуры

// ****************************************************************************
// Инициализация и запуск скрипта
// ****************************************************************************

ПриНачалеРаботы();

Попытка	
	Главная();
	updater.КодПользователяВыполнился();
Исключение
	errors = Истина;
	Сообщить("<span class='red'><b>" + ОписаниеОшибки() + "</b></span>");
КонецПопытки;

ПриОкончанииРаботы();