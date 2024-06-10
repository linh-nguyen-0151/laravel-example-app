import "./bootstrap";

Echo.channel('notifications')
    .listen('UserSessionChanged', (e) => {
        console.log(e);
        alert(1);
    })
