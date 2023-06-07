/*
 * Custom JavaScript
 */
$(window).on('load', function(){
    var body = document.getElementsByTagName('body')[0];
    var hamburgermenu = this.template.querySelector("input.menu-btn");
    console.log("Hello ", hamburgermenu.checked = false);
    if (hamburgermenu.checked){
        body.classList.add("menuOpened");
    } else {
        console.log("Not Checked");
        body.classList.add("menuOpened");
    }
    $('input.menu-btn').on('change', function () {
        if ($(this).is(":checked")) {
            alert('checked');
        } else {
            alert('not checked');
        }
    });
});
/*window.addEventListener('load', function() {
    var body = document.getElementsByTagName('body')[0];
    var hamburgermenu = document.getElementsByClassName("menu-btn");
    $(hamburgermenu).change(function(){
        if($(this).is(":checked")) {
            $(body).addClass("menuOpened");
        } else {
            $(body).removeClass("menuOpened");
        }
    });
    /*if (hamburgermenu.checked){
        body.classList.add("menuOpened");
    } else {
        console.log("Not checked");
        body.classList.remove("menuOpened");
    }
})
/*document.getElementsByClassName("menu-btn").addEventListener('change', function() {
    var body = document.getElementsByTagName('body')[0];
    if (this.checked) {
        body.classList.add("menuOpened");
    } else {
        body.classList.remove("menuOpened");
    }
});*/