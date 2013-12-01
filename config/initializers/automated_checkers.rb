unless Rails.env.development?
  # In development this will only work on the first request - due to auto-reloading of classes, but
  # initializers wont be run again

  Sapphire::AutomatedCheckers::Central.register Sapphire::AutomatedCheckers::EmailChecker
  Sapphire::AutomatedCheckers::Central.register Sapphire::AutomatedCheckers::AssetCountChecker
  Sapphire::AutomatedCheckers::Central.register Sapphire::AutomatedCheckers::DeadlineChecker
  Sapphire::AutomatedCheckers::Central.register Sapphire::AutomatedCheckers::Ex31Checker
end