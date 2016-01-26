#Create Admin
Admin.where(:email => 'admin@futurify.vn').first || Admin.create({
      email:     'admin@futurify.vn',
      password:  'admin1234',
      enabled: true
    })
