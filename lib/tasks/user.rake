namespace :user do
  desc "Create user"
  task :create, [:email, :password, :role] => :environment do |t, args|

    errors = []
    errors.append("- не указана почта") if args.email.to_s.empty?
    errors.append("- не указан пароль или он меньше 8 символов") if args.password.to_s.empty? || args.password.size < 8
    errors.append("- не указана или не найдена роль") if args.role.to_s.empty? || !(User.roles.include?(args.role.to_sym))

    if errors.count > 0
      puts "Не возможно создать пользователя:"
      puts errors.join("\n")
      abort
    end

    user = User.where(email: args.email).first
    abort "Пользователь уже существует \n" unless user.nil?

    User.create!(
        email:                  args.email,
        password:               args.password,
        password_confirmation:  args.password,
        role:                   args.role.to_sym
    ).save

    puts "Пользователь успешно создан."
  end

  desc "User list"
  task :list, [:role] => :environment do |t, args|
    users = User
    users = users.where(role: args.role) unless args.role.to_s.empty?

    max_size = 0
    prints = {}
    users.each do |user|
      max_size = user.email.size if user.email.size > max_size
      prints[user.email] = user.role
    end

    prints.each { |email, role| puts "#{ email.ljust(max_size, " ") } \t #{ role }"}
  end

  desc "Delete user"
  task :delete, [:email] => :environment do |t, args|
    abort "Не указан пользователь" if args.email.to_s.empty?

    user = User.where(email: args.email).first
    abort "Пользователь не найден" if user.nil?

    user.delete
    puts "Пользователь успешно удален"
  end

  desc "Update user"
  task :update, [:email, :password, :role, :new_email] => :environment do |t, args|
    params = {}

    abort "Не указан пользователь" if args.email.to_s.empty?

    user = User.where(email: args.email).first
    abort "Пользователь не найден" if user.nil?

    unless args.password.to_s.empty?
      abort "Пароль меньше 8 символов" if args.password.size < 8

      params[:password] = args.password
      params[:password_confirmation] = args.password
    end

    unless args.role.to_s.empty?
      abort "Не верно указана роль" unless User.roles.include? args.role.to_sym
      params[:role] = args.role.to_sym
    end

    unless args.new_email.to_s.empty?
      params[:email] = args.new_email
    end

    abort "Не указаны параметры для изменения" if params.count == 0
    user.update_attributes!(params)

    puts "Данные пользователя успешно обновлены"
  end


  desc "Reset password"
  task :reset, [:email] => :environment do |t, args|
    abort "Не указан пользователь" if args.email.to_s.empty?

    user = User.where(email: args.email).first
    abort "Пользователь не найден" if user.nil?

    user.send_reset_password_instructions
    puts "Инструкция для восстановления пароля выслана на почту."
  end

  task :activate, [:email] => :environment do |t, args|
    abort "Не указан пользователь" if args.email.to_s.empty?

    user = User.where(email: args.email).first
    abort "Пользователь не найден" if user.nil?

    user.update_attributes!(active: true)
    puts "Пользователь активирован."
  end

  task :deactivate, [:email] => :environment do |t, args|
    abort "Не указан пользователь" if args.email.to_s.empty?

    user = User.where(email: args.email).first
    abort "Пользователь не найден" if user.nil?

    user.update_attributes!(active: false)
    puts "Пользователь деактивирован."
  end



end