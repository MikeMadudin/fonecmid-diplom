
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СоздатьРеализации(Команда)
	
	Если Не ЗначениеЗаполнено(Объект.Период) Тогда
		ТекстСообщения = "Не заполнен период.";
		ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, , "Период", "Объект.Период", );
		Возврат;	
	КонецЕсли;
	
	Объект.СписокДоговоров.Очистить();
	
	//@skip-check notify-description-to-server-procedure
	//@skip-check bsl-legacy-check-string-literal
	ОповещениеОЗавершении = Новый ОписаниеОповещения("ОповещениеОЗавершении", ЭтотОбъект);

	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ПараметрыОжидания.Интервал = 1;
	ПараметрыОжидания.ВыводитьОкноОжидания = Истина;

	ДлительнаяОперация = СоздатьРеализацииНаСервере();

	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания); 
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция СоздатьРеализацииНаСервере()

	Возврат ДлительныеОперации.ВыполнитьФункцию(УникальныйИдентификатор,
		"Обработки.ВКМ_МассовоеСозданиеАктов.СоздатьРеализацииПакетом", Объект.Период);

КонецФункции

&НаСервере
Процедура ОповещениеОЗавершении(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат.Статус = "Выполнено" Тогда
		СозданныеРеализации = ПолучитьИзВременногоХранилища(Результат.АдресРезультата);
		Если ЗначениеЗаполнено(СозданныеРеализации) Тогда
			Для Каждого Реализация Из СозданныеРеализации Цикл
				НоваяСтрока = Объект.СписокДоговоров.Добавить();
				НоваяСтрока.Реализация = Реализация;
				//@skip-check bsl-legacy-check-string-literal
				НоваяСтрока.Договор = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Реализация, "Договор");
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли