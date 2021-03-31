# frozen_string_literal: true

namespace :locales do
  desc 'Create locale export'
  task export: :environment do
    start_time = Time.now

    LocalesExportImport::Yaml2Csv.convert(
      %w[config/locales/simple_form_en.yml config/locales/simple_form_de.yml config/locales/simple_form_fr.yml config/locales/simple_form_it.yml config/locales/simple_form_nl.yml config/locales/simple_form_pl.yml  config/locales/simple_form_ru.yml],
      'en_de_fr_ru_it_nl_pl_simpleform_keys.csv'
    )

    LocalesExportImport::Yaml2Csv.convert(
      %w[config/locales/en.yml config/locales/de.yml config/locales/fr.yml config/locales/it.yml config/locales/nl.yml config/locales/pl.yml config/locales/ru.yml],
      'en_de_fr_ru_it_nl_pl_keys.csv'
    )

    log("Task completed in #{Time.now - start_time} seconds.")
  end
  task import: :environment do
    start_time = Time.now
    csv_file_name = 'en_de_fr_ru_it_nl_pl_simpleform_keys.csv'
    LocalesExportImport::Csv2Yaml.convert(csv_file_name, 'config/locales/', 'simple_form_')
    csv_file_name = 'en_de_fr_ru_it_nl_pl_keys.csv'
    LocalesExportImport::Csv2Yaml.convert(csv_file_name, 'config/locales/', '')
    log("Task completed in #{Time.now - start_time} seconds.")
  end
  def log(msg)
    puts msg
    Rails.logger.info msg
  end
end
