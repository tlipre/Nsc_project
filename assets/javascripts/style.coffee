$ ->
	color = ['#06B293','#EB9C00','#2F7CE1']
	i = 0
	while i < 3
	  random = Math.floor(Math.random() * 3)
	  result = color[random]
	  $("article .class-header").eq(i).css("background-color",result)
	  i++
