# frozen_string_literal: true

namespace :locales do
  desc 'Create locale export'
  task export: :environment do
    start_time = Time.now

    LocalesExportImport::Yaml2Csv.convert(
      %w[config/locales/simple_form.en.yml config/locales/simple_form.de.yml],
      'en_de_simpleform_keys.csv'
    )

    LocalesExportImport::Yaml2Csv.convert(
      %w[config/locales/en.yml config/locales/de.yml],
      'en_de_keys.csv'
    )

    log("Task completed in #{Time.now - start_time} seconds.")
  end
  task import: :environment do
    start_time = Time.now
    csv_file_name = 'en_de_fr_it_pl_nl_simpleform_keys.csv'
    LocalesExportImport::Csv2Yaml.convert(csv_file_name, 'config/locales/', 'simple_form_')
    csv_file_name = 'en_de_fr_it_pl_nl_keys.csv'
    LocalesExportImport::Csv2Yaml.convert(csv_file_name, 'config/locales/', '')
    log("Task completed in #{Time.now - start_time} seconds.")
  end
  def log(msg)
    puts msg
    Rails.logger.info msg
  end
end
