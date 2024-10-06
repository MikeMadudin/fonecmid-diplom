
#Область ПрограммныйИнтерфейс

// Процедура отправляет уведомление в телеграм
//
// Параметры:
//  ТекстСообщения - Строка - Текст уведомления
Процедура ОтправкаСообщенияВТелеграм(ТекстСообщения) Экспорт
	
	Токен = Константы.ВКМ_ТокенТелеграмБота.Получить();
	
	ДанныеДляЗапроса = Новый Структура;
	ДанныеДляЗапроса.Вставить("chat_id", Константы.ВКМ_ИдентификаторГруппыДляОповещения.Получить());
	ДанныеДляЗапроса.Вставить("text", ТекстСообщения);
	
	ЗащищенноеСоединениеOpenSSL = Новый ЗащищенноеСоединениеOpenSSL;
	HTTPСоединение = Новый HTTPСоединение("api.telegram.org", , , , , , ЗащищенноеСоединениеOpenSSL);
	
	АдресРесурса = "/bot" + Токен + "/sendMessage";
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, ДанныеДляЗапроса);
	JSONСтрока = ЗаписьJSON.Закрыть();

	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "application/json; charset=utf-8");

	HTTPЗапрос = Новый HTTPЗапрос(АдресРесурса, Заголовки);
	HTTPЗапрос.УстановитьТелоИзСтроки(JSONСтрока, "UTF-8", ИспользованиеByteOrderMark.НеИспользовать);

	HTTPОтвет = HTTPСоединение.ВызватьHTTPМетод("POST", HTTPЗапрос);
	КодСостояния = HTTPОтвет.КодСостояния;

	ОтветСтрокаJSON = HTTPОтвет.ПолучитьТелоКакСтроку();
	ОтветЧтениеJSON = Новый ЧтениеJSON;
	ОтветЧтениеJSON.УстановитьСтроку(ОтветСтрокаJSON);

	Если НЕ КодСостояния = 200 Тогда
		ДобавитьЗаписьВЖурналРегистрации(АдресРесурса, JSONСтрока, ОтветСтрокаJSON);
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Процедура добавляет запись в журнал регистрации текста запроса и ответа в случае ошибки отправки уведомления
//
// Параметры:
//  АдресРесурса - Строка - Текст уведомления
//  ТекстЗапроса - Строка - Текст запроса
//  ТекстОтвета - Строка - Текст ответа от сервера
Процедура ДобавитьЗаписьВЖурналРегистрации(АдресРесурса, ТекстЗапроса, ТекстОтвета) Экспорт
	
	ТекстКомментария = Строка(ТекущаяДатаСеанса()) + Символы.ПС 
						+ "Текст запроса:" + Символы.ПС + ТекстЗапроса + Символы.ПС
						+ "Текст ответа:" + Символы.ПС + ТекстОтвета;
	ЗаписьЖурналаРегистрации(АдресРесурса, УровеньЖурналаРегистрации.Ошибка,,, ТекстКомментария);

КонецПроцедуры

#КонецОбласти