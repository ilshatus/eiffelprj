$(function(){
	$("#queries-block select").change(function() {
		setParameters('-1');
		setParameters($("#queries-block select :selected").val())
	});
});


var textRegex = new RegExp("^[a-zA-Z0-9'\",.:?!\\-() ]+$");
var dateRegex = new RegExp("^((0[1-9])|([12][0-9])|(3[01])).((0[1-9])|(1[0-2])).[0-9]{4}$");
var yearRegex = new RegExp("^[0-9]{4}$");
var numberRegex = new RegExp("^[0-9]+$");

function setParameters(option) {
	switch (option) {
		case '0':
			$("#queries-block").append('<div class="parameters-block"><label>Year (format: "yyyy")<br><input type="number" id="par0" class=""></label></div>');
			$("#queries-block").append('<button class="button" id="getBtn">GET</button>');
			break;
		case '2':
			$("#queries-block").append('<div class="parameters-block"><label>Initial date<br><input type="c_date" id="par0" class="date"></label></div>');
			$("#queries-block").append('<div class="parameters-block"><label>Final date<br><input type="c_date" id="par1" class="date"></label></div>');
			$("#queries-block").append('<button class="button" id="getBtn">GET</button>');
			break;
		case '1':
		case '3':
		case '4':
		case '5':
		case '6': 
			$("#queries-block").append('<div class="parameters-block"><label>Unit name<br><input type="text" id="par0" class=""></label></div>');
			$("#queries-block").append('<button class="button" id="getBtn">GET</button>');
			break;
		default:
			$('.parameters-block').remove();
			$('.button').remove();
	}
	setCharConstraintsToParametersBlock();
}

function setCharConstraintsToParametersBlock() {
	$("#getBtn").click(function(){
		if (!makeQuery()) return;
		$("#queries-block select :first").removeAttr("selected");
		$("#queries-block select :first").attr("selected", "selected");
		setParameters('-1');
	});
	$('.parameters-block input[type="c_date"]').datepicker({dateFormat: "dd.mm.yy"});
	$('.parameters-block input[type="text"]').keypress(function (e) {
		var str = String.fromCharCode(!e.charCode ? e.which : e.charCode);
	   	if (textRegex.test(str)) {
	    	return true;
	   	}
	   	e.preventDefault();
		return false;
	});
	$('.parameters-block input[type="number"]').keypress(function (e) {
		var str = String.fromCharCode(!e.charCode ? e.which : e.charCode);
	   	if (numberRegex.test(str)) {
	    	return true;
	   	}
	   	e.preventDefault();
		return false;
	});
}

function checkParametrs(option) {
	switch (option) {
		case '0':
			if (yearRegex.test($("#par0").val())) {
				$('#par0').css('border', 'grey 1px solid');
				return true;
			} else {
				$('#par0').css('border', 'red 1px solid');
				return false;
			}
		case '2':
			var isGood = true;
			if (dateRegex.test($("#par0").val())) {
				$('#par0').css('border', 'grey 1px solid');
			} else {
				$('#par0').css('border', 'red 1px solid');
				isGood = false;
			}
			if (dateRegex.test($("#par1").val())) {
				$('#par1').css('border', 'grey 1px solid');
			} else {
				$('#par1').css('border', 'red 1px solid');
				isGood = false;
			}
			return isGood;
		case '1':
		case '3':
		case '4':
		case '5':
		case '6': 
			if (textRegex.test($("#par0").val())) {
				$('#par0').css('border', 'grey 1px solid');
				return true;
			} else {
				$('#par0').css('border', 'red 1px solid');
				return false;
			}
		default: return false;
	} 
}

function reformatDate(date) {
	if (dateRegex.test(date)) {
		date = date.split('.');
		return date[2] + '-' + date[1] + '-' + date[0];
	}
}

function makeQuery() {
	var option = $("#queries-block select :selected").val();
	if (!checkParametrs(option)) return false;
	var queryUrl = '/admin/query/' + option + '?';
	if (option == '2') {
		queryUrl += 'par0=' + reformatDate($("#par0").val());
		queryUrl += '&par1=' + reformatDate($("#par1").val());
	} else {
		queryUrl += 'par0=' + $("#par0").val();
	}
	$.ajax({
		dataType: 'json',
  		url: queryUrl,
  		async: false,
  		success: function(data) {
  			$('#content-block').text('');
  			switch (option) {
  				case '0':
  					$('#content-block').append('<h1>Conference publications:</h1>');
  					$('#content-block').append('<hr>');
  					$('#content-block').append('<ul id="c-publications" style="list-style: circle"></ul>');
  					if (data.conference_publications.length == 0) {
  						$('#c-publications').append('<li><span style="color: red">There is no conference publications!</span></li>');
  					}
  					for (var publication in data.conference_publications) {
  						$('#c-publications').append('<li><span>' + data.conference_publications[publication] + '</span></li>')
  					}
  					$('#content-block').append('<hr>');
  					$('#content-block').append('<h1>Journal publications:</h1>');
  					$('#content-block').append('<hr>');
  					$('#content-block').append('<ul id="j-publications" style="list-style: circle"></ul>');
  					if (data.journal_publications.length == 0) {
  						$('#j-publications').append('<li><span style="color: red">There is no journal publications!</span></li>');
  					}
  					for (var publication in data.journal_publications) {
  						$('#j-publications').append('<li><span>' + data.journal_publications[publication] + '</span></li>')
  					}
  					$('#content-block').append('<hr>');
  					break;
				case '1':
					$('#content-block').append('<h1>Cumulative information:</h1>');
					$('#content-block').append('<hr>');
					if (data.length == 0) {
						$('#content-block').append('<ul style="list-style: circle"><li><span style="color: red">There is no information!</span></li></ul>')
						$('#content-block').append('<hr>');
					}
					for (var i = 0; i < data.length; i++) {
						var id0 = "first-layer" + i;
						$('#content-block').append('<ul id="' + id0 + '" style="list-style: circle"></ul>');
						var j = 0;
						for (var fieldName in data[i]) {
							var li0Id = id0 + '_' + j;
							$('#' + id0).append('<li id="' + li0Id + '">' + fieldName + ': </li>')
							var id1 = "second-layer" + i + '_' + j;
							$('#' + id0).append('<ul id="' + id1 + '" style="list-style: circle"></ul>');
							if (typeof(data[i][fieldName]) == 'string') {
								if (data[i][fieldName] == '') {
									$('#' + li0Id).append('<span style="color: red">none</span>');
								}
								else
									$('#' + li0Id).append('<span>' + data[i][fieldName] + '</span>');
							} else {
								for (var k in data[i][fieldName]) {
									if (k > 0) {
										$('#' + id1).append('<hr>');
									}
									for (var pararmeterName in data[i][fieldName][k]) {
										if (data[i][fieldName][k][pararmeterName] == '') {
											$('#' + li0Id).append('<span style="color: red">none</span>');
											break;
										}
										$('#' + id1).append('<li>' + pararmeterName + ': <span>' + data[i][fieldName][k][pararmeterName] + '</span></li>');
									}
								}
							}
							j++;
						}
						$('#content-block').append('<hr>');
					}
					break;
				case '2':
					$('#content-block').append('<h1>Courses taught:</h1>');
					$('#content-block').append('<hr>');
					if (data.length == 0) {
						$('#content-block').append('<ul style="list-style: circle"><li><span style="color: red">There is no information!</span></li></ul>')
						$('#content-block').append('<hr>');
					}
					for (var i = 0; i < data.length; i++) {
						var id0 = "first-layer" + i;
						$('#content-block').append('<ul id="' + id0 + '" style="list-style: circle"></ul>');
						for (var pararmeterName in data[i]) {
							$('#' + id0).append('<li>' + pararmeterName + ': <span>' + data[i][pararmeterName] + '</span></li>');
						}
						$('#content-block').append('<hr>');
					}
					break;
				case '3':
					$('#content-block').append('<h1>Number of supervised students: <span>' + data.number_of_students + '</span></h1>');
					$('#content-block').append('<hr>');
					break;
				case '4':
					$('#content-block').append('<h1>Number of research collaborations: <span>' + data.number_of_res_cols + '</span></h1>');
					$('#content-block').append('<hr>');
					break;
				case '5':
					$('#content-block').append('<h1>List of PHDs:</h1>');
  					$('#content-block').append('<hr>');
  					$('#content-block').append('<ul id="c-publications" style="list-style: circle"></ul>');
  					if (data.list_of_phds.length == 0) {
  						$('#c-publications').append('<li><span style="color: red">There is no information!</span></li>');
  					}
  					for (var i in data.list_of_phds) {
  						$('#c-publications').append('<li><span>' + data.list_of_phds[i] + '</span></li>')
  					}
 					$('#content-block').append('<hr>');
					break;
				case '6':
					$('#content-block').append('<h1>List of patents:</h1>');
					$('#content-block').append('<hr>');
					if (data.length == 0) {
						$('#content-block').append('<ul style="list-style: circle"><li><span style="color: red">There is no information!</span></li></ul>')
						$('#content-block').append('<hr>');
					}
					for (var i = 0; i < data.length; i++) {
						var id0 = "first-layer" + i;
						$('#content-block').append('<ul id="' + id0 + '" style="list-style: circle"></ul>');
						for (var pararmeterName in data[i]) {
							$('#' + id0).append('<li>' + pararmeterName + ': <span>' + data[i][pararmeterName] + '</span></li>');
						}
						$('#content-block').append('<hr>');
					}
					break;
  			}
  		},
  		error: function() {
  			alert("Something has gone wrong!");
  		}
	});
	return true;
}