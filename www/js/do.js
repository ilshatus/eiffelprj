
$(function(){
	loadPages();
	$("#next-page").click(function() {
		if (currentPage == numberOfPages - 1) return;
		if (!checkFields(currentPage)) return;
		resetPage();
		currentPage++;
		setPage();
		setButtons();
	});
    $('#previous-page').click(function() {
    	if (currentPage == 0) return;
    	resetPage();
		currentPage--;
		setPage();
		setButtons();
    });
    $('#submit').click(function(e){
    	if (!checkFields(currentPage)) return;
    	if (sendForm()) {

    	}
    	else {

    	}
    });
    $('.button').click(function() {
    	var fullId = $(this).attr('id');
    	var id = getRealIdOfAddingButton(fullId);
    	if (id != null) {
    		openOverlayBlock(id);
    		setCharConstraintsToOverlayBlock();
    	}
    	var id = getRealIdOfRemovingButton(fullId);
    	if (id != null) {
    		removeLastInputOfField(id);
    	}
    });
    $('input[type="c_date"]').datepicker({dateFormat: "dd.mm.yy"});
    $('.inside-block input[type="text"]').keypress(function (e) {
    	var id = $(this).attr('id');
    	var id = id.substr('field'.length, id.length);
    	if (!fieldInfo[id].multiple_values) {
			var str = String.fromCharCode(!e.charCode ? e.which : e.charCode);
		   	if (textRegex.test(str)) {
		    	return true;
		   	}
	   		e.preventDefault();
			return false;
		}
	});

});


var currentPage = 0;
var numberOfPages = 0;
var pageInfo = [];
var pageFields = [];
var fieldInfo = [];
var currentField = -1;
var textRegex = new RegExp("^[a-zA-Z0-9'\",.:?!\\-() ]+$");
var dateRegex = new RegExp("^((0[1-9])|([12][0-9])|(3[01])).((0[1-9])|(1[0-2])).[0-9]{4}$");
var numberRegex = new RegExp("^[0-9]+$");
var isOverlayOpened = false;


function reloadPage() {
	location.reload();
}


function sendForm() {
	if (!checkAllFields()) return false;
	var jsonArray = [];
	for (var i = 0; i < numberOfPages; i++) {
		for (var j = 0; j < pageFields[i].length; j++) {
			var id = pageFields[i][j];
			if (fieldInfo[id].format == 'date' && $('#field' + id).val() != "") 
				jsonArray.push(reformatDate($('#field' + id).val()));
			else 
				jsonArray.push($('#field' + id).val().replace('\n', ''));
		}
	}
	$.ajax({
  		url: 'send/form',
  		type: 'POST',
  		data: 'jsonData=' + JSON.stringify(jsonArray), 
  		success: function(data) {
  			createOverlay();
			$('#overlay').append('<div id="overlay-inside-block"></div>');
			$('#overlay-inside-block').append('<div id="response" class="content-block" style="margin-top: 5px"></div>');
			if (data == 'ok') {
				$('#response').append('<span class="good-response">Your report has been succesfully added!</span>');
			} else {
				$('#response').append('<span class="error-response">' + data + '</span>');
			}
			setTimeout(reloadPage, 2000);
  		},
  		error: function() {
  			alert("sendForm error!");
  			setTimeout(reloadPage, 1000);
  		}
	});
}

function resetPage() {
	$('#page-info-block').text('');
	$('#page' + currentPage).hide(300);
}

function setPage() {
	$('#page-info-block').append('<h1>' + pageInfo[currentPage].name + '</h1>');
	$('#page-info-block').append('<p>' + pageInfo[currentPage].description + '</p><span style="color: red; font: 120% serif">* Obligatory</span>');
	$('#page' + currentPage).show(300);
}

function setButtons() {
	if (numberOfPages == 1) {
		$('#previous-page').hide(200);
		$('#next-page').hide(200);
		$('#submit').show(200);
		return;
	}
	if (currentPage == 0) {
		$('#previous-page').hide(200);
		$('#next-page').show(200);
		$('#submit').hide(200);
	} else if (currentPage == numberOfPages - 1) {
		$('#previous-page').show(200);
		$('#next-page').hide(200);
		$('#submit').show(200);
	} else {
		$('#previous-page').show(200);
		$('#next-page').show(200);
		$('#submit').hide(200);
	}
}

function addPage(page) {
	pageInfo[page.id] = page;
	$("#pre-inside-block").append('<div id="page' + page.id + '" class="inside-block"></div>');
	loadFields(page.id);
}

function loadFields(pageId) {
	$.ajax({
		dataType: 'json',
  		url: 'load/fields?pageId=' + pageId ,
  		async: false,
  		success: function(data) {
  			pageFields[pageId] = [];
  			for (var i = 0; i < data.length; i++) {
  				pageFields[pageId][i] = data[i].id;
  				fieldInfo[data[i].id] = data[i];
  				addField(data[i], pageId);
  			}
  		},
  		error: function() {
  			alert("fields loading error!");
  		}
	});
}

function addField(field, pageId) {
	if (field.obligatory) 
		$('#page' + pageId).append('<h1>' + field.name + ' <span style="color:red">*</span></h1>');
	else 
		$('#page' + pageId).append('<h1>' + field.name + '</h1>');
	$('#page' + pageId).append('<p>' + field.description + '</p>')
	if (!field.multiple_values) {
		$('#page' + pageId).append('<input type="' + field.type + '" class="' + field.class + '" id="field' + field.id + '">');
	} else {
		$('#page' + pageId).append('<textarea id="field' + field.id + '" readonly></textarea>');
		$('#page' + pageId).append('<button id="add_field_btn' + field.id + '" class = "button" type="button">Add</button>');
		$('#page' + pageId).append('<button id="rem_field_btn' + field.id + '" class = "button" type="button">Remove last</button>');
	}
	$('#page' + pageId).append('<p id="error'+ field.id +'" class="error"></p>');
}

function loadPages() {
	$.ajax({
		dataType: 'json',
  		url: 'load/pages',
  		async: false,
  		success: function(data) {
   			//data = JSON.parse(data);		
  			numberOfPages = data.length;
    		for (var i = 0; i < data.length; i++) {
    			addPage(data[i]);
    		}
    		setPage();
			setButtons();
  		},
  		error: function() {
  			alert("pages loading error!");
  		}
	});
}

function isNumeric(n) {
  return !isNaN(parseInt(n)) && isFinite(n);
}

function isCorrectFormatOfDate(date) {
	return dateRegex.test(date);
}

function isCorrectFormatOfText(text) {
	return textRegex.test(text);
}

function getRealIdOfAddingButton(fullId) {
	var id = fullId.substr(0, 'add_field_btn'.length);
	if (id == 'add_field_btn') {
		return fullId.substr('add_field_btn'.length, fullId.length);
	}
	return null;
}

function getRealIdOfRemovingButton(fullId) {
	var id = fullId.substr(0, 'rem_field_btn'.length);
	if (id == 'rem_field_btn') {
		return fullId.substr('rem_field_btn'.length, fullId.length);
	}
	return null;
}

function openOverlayBlock(id) {
	if (isOverlayOpened) return;
	currentField = id;
	var field = fieldInfo[id];
	createOverlay();
	isOverlayOpened = true;
	$('#overlay').append('<div id="overlay-inside-block"></div>');
	$('#overlay-inside-block').append('<div class="content-block"><h1>' + field.name + '</h1></div>');
	$('#overlay-inside-block').append('<div id="content-block-input" class="content-block"></div>');
	var insideField = field.format.split('-');
	for (var i = 0; i < insideField.length; i++) {
		var curr = insideField[i].split('^');
		var type = 'text';
		var _class = '';
		if (curr.length == 2) type = curr[1];
		if (type == 'date') {
			_class = type;
			type = 'c_' + type;
		}
		$('#content-block-input').append('<p>' + curr[0] + '<span style="color:red"> *</span></p>')
		$('#content-block-input').append('<input id="overlay-field' + i + '" type="' + type + '" class="' + _class + '">');
	}
	$('#overlay-inside-block').append('<div id="content-block-buttons" class="content-block"></div>');
	$('#content-block-buttons').append('<button id="overlay-add" class="button" type="button">Add</button>');
	$('#content-block-buttons').append('<button id="overlay-close" class="button" type="button">Close</button>');
	$('#overlay-add').click(function() {
		if (!fillCurrentField()) return;
    	currentField = -1;
    	$('#overlay').remove();
    	isOverlayOpened = false;
	});
	$('#overlay-close').click(function() {
    	currentField = -1;
    	$('#overlay').remove();
    	isOverlayOpened = false;
	});
}

function createOverlay(){
  var docHeight = $(document).height();
  $('<div id="overlay"></div>')
  .appendTo("body")
  .height(docHeight);
}

function setCharConstraintsToOverlayBlock() {
	$('#overlay input[type="c_date"]').datepicker({dateFormat: "dd.mm.yy"});
	$('#overlay input[type="text"]').keypress(function (e) {
		var str = String.fromCharCode(!e.charCode ? e.which : e.charCode);
	   	if (isCorrectFormatOfText(str)) {
	    	return true;
	   	}
	   	e.preventDefault();
		return false;
	});
	$('#overlay input[type="number"]').keypress(function (e) {
		var str = String.fromCharCode(!e.charCode ? e.which : e.charCode);
	   	if (numberRegex.test(str)) {
	    	return true;
	   	}
	   	e.preventDefault();
		return false;
	});
}

function reformatDate(date) {
	if (isCorrectFormatOfDate(date)) {
		date = date.split('.');
		return date[2] + '-' + date[1] + '-' + date[0];
	}
}

function fillCurrentField() {
	field = fieldInfo[currentField];
	var insideField = field.format.split('-');
	var str = '';
	var isGood = true;
	for (var i = 0; i < insideField.length; i++) {
		var curr = insideField[i].split('^');
		var fieldVal = $('#overlay-field' + i).val();
		if (fieldVal == '' || curr.length == 1 && !isCorrectFormatOfText(fieldVal) ||
			curr.length == 2 && (curr[1] == 'date' && !isCorrectFormatOfDate(fieldVal) || 
				curr[1] == 'number' && !isNumeric(fieldVal))) {
			$('#overlay-field' + i).css('border', 'red 1px solid');
			isGood = false;
		} else {
			$('#overlay-field' + i).css('border', 'grey 1px solid');
		}
		str += $('#overlay-field' + i).val();
		if (i != insideField.length - 1) str += '/';
	}
	if (!isGood) return false;
	if ($('#field' + field.id).val() != '')
	str = $('#field' + field.id).val() + ';\n' + str;
	$('#field' + field.id).val(str);
	return true;
}

function removeLastInputOfField(id) {
	var value = $('#field' + id).val().split(';\n');
	var newValue = '';
	for (var i = 0; i < value.length - 1; i++) {
		if (i != 0) newValue += ';\n';
		newValue += value[i];
	}
	$('#field' + id).val(newValue);
}

function setFieldToGoodState(id) {
	$('#field'+id).css('border', 'grey 1px solid');
	$('#error'+id).text('');
}

function checkFieldByFormat(field) {
	if (!field.multiple_values) {
		return isCorrectFormatOfText($('#field' + field.id).val());
	}
	var formats = field.format.split('-');
	var fieldParametrs = $('#field' + field.id).val().split(';\n');
	for (var i = 0; i < fieldParametrs.length; i++) {
		var currParametr = fieldParametrs[i].split('/');
		if (currParametr.length != formats.length) return false;
		for (var j = 0; j < currParametr.length; j++) {
			var parametrFormat = formats[j].split('^');
			if (parametrFormat.length == 1 && !isCorrectFormatOfText(currParametr[j])) {
				return false;
			}
			else {
				if (parametrFormat[1] == 'date' && !isCorrectFormatOfDate(currParametr[j]) ||
						parametrFormat[1] == 'number' && !isNumeric(currParametr[j])) {
					return false;
				}
			}
		}
	}
	return true;
}

function checkField(field) {
	if ($('#field'+field.id).val() == '' && field.obligatory) {
		$('#field'+field.id).css('border', 'red 1px solid');
		$('#error'+field.id).text('The field can not be empty')
		return false;
	} else if ($('#field' + field.id).val() != '') {
		if (field.format == 'date') {
			if (!isCorrectFormatOfDate($('#field' + field.id).val())) {
				$('#field'+field.id).css('border', 'red 1px solid');
				$('#error'+field.id).text('Wrong format of the date');
				return false;
			}
			setFieldToGoodState(field.id);
			return true;
		} else {
			if (!checkFieldByFormat(field)) {
				$('#field'+field.id).css('border', 'red 1px solid');
				$('#error'+field.id).text('Wrong format of the field');
				return false;
			}
			setFieldToGoodState(field.id);
			return true;
		}
	} else {
		setFieldToGoodState(field.id);
		return true;
	}
}

function checkFields(page) {
	var isGood = true;
	for (var i = 0; i < pageFields[page].length; i++) {
		var field = fieldInfo[pageFields[page][i]];
		if (!checkField(field)) {
			isGood = false;
		}
	}
	return isGood;
}

function checkAllFields() {
	var isGood = true;
	for (var i = 0; i < numberOfPages; i++) {
		if (!checkFields(i)) isGood = false;
	}
	return isGood;
}