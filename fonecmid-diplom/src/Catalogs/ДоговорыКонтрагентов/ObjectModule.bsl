
// +++ Мадудин М. 09.10.2024
// Добавлено приведение периодов к концу или началу дня
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ВКМ_ПериодДействияНачало = НачалоДня(ВКМ_ПериодДействияНачало);
	ВКМ_ПериодДействияКонец = КонецДня(ВКМ_ПериодДействияКонец);

КонецПроцедуры

#КонецОбласти

#КонецЕсли
// --- Мадудин М. 09.10.2024