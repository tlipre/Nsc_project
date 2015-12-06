console.log("mamieo");

$(document).ready(function(){
    $(".intro .btn.start").click(function(){
        $(".goal .col-md-3").animate({top: '250px'});
        console.log("animate");
    });
});


