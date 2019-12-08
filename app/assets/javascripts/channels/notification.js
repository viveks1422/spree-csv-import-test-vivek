App.notification = App.cable.subscriptions.create('NotificationChannel', {  
  received: function(data) {
    console.log(data);
    return $('.' + data.notification_data.alert_class).html(data.notification_data.message).css("display", "block");
  }
});