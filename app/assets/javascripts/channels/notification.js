App.notification = App.cable.subscriptions.create('NotificationChannel', {  
  received: function(data) {
    console.log(data);
    
  }
});