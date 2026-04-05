# Валидатор CSV перед сборкой Jekyll
# Проверяет структуру products.csv. При ошибках — жёстко прерывает сборку.

Jekyll::Hooks.register :site, :after_reset do |site|
  csv_path = File.join(site.source, '_data', 'products.csv')
  next unless File.exist?(csv_path)

  require 'csv'

  errors   = []
  warnings = []

  begin
    rows = CSV.read(csv_path, headers: true)
  rescue CSV::MalformedCSVError => e
    abort("[CSV Validator] Не удалось разобрать products.csv — #{e.message}")
  end

  # Обязательные поля
  REQUIRED_FIELDS = %w[id title price images slug].freeze
  missing_fields = REQUIRED_FIELDS - rows.headers.to_a
  unless missing_fields.empty?
    errors << "Отсутствуют обязательные колонки: #{missing_fields.join(', ')}"
  end

  seen_ids   = {}
  seen_slugs = {}

  rows.each_with_index do |row, i|
    line = i + 2 # строка в файле с учётом заголовка

    # Пустые обязательные значения
    REQUIRED_FIELDS.each do |field|
      next unless rows.headers.include?(field)
      val = row[field].to_s.strip
      if val.empty?
        errors << "Строка #{line}: пустое поле '#{field}'"
      end
    end

    # Цена — число (ошибка: NaN сломает JS-корзину)
    price = row['price'].to_s.strip
    unless price.match?(/\A\d+(\.\d+)?\z/)
      errors << "Строка #{line}: цена '#{price}' не является числом — сломает parseFloat() в корзине"
    end

    # Дублирующийся id
    id = row['id'].to_s.strip
    if seen_ids[id]
      errors << "Строка #{line}: дублирующийся id '#{id}' (первый раз — строка #{seen_ids[id]})"
    else
      seen_ids[id] = line
    end

    # Дублирующийся slug
    slug = row['slug'].to_s.strip
    if !slug.empty? && seen_slugs[slug]
      errors << "Строка #{line}: дублирующийся slug '#{slug}' (первый раз — строка #{seen_slugs[slug]})"
    else
      seen_slugs[slug] = line unless slug.empty?
    end

    # Формат images — должны быть URL
    images = row['images'].to_s.strip
    unless images.empty?
      images.split(';').each do |img|
        img.strip!
        unless img.match?(/\Ahttps?:\/\/\S+\z/)
          warnings << "Строка #{line}: подозрительный URL изображения '#{img}'"
        end
      end
    end

    # Slug не должен содержать кириллицу или пробелы
    if slug.match?(/[а-яёА-ЯЁ\s]/)
      warnings << "Строка #{line}: slug '#{slug}' содержит кириллицу или пробелы"
    end
  end

  # Вывод результатов
  total = rows.length
  Jekyll.logger.info "CSV Validator:", "Проверено #{total} товаров в products.csv"

  warnings.each { |w| Jekyll.logger.warn  "CSV Validator:", w }

  if errors.empty?
    Jekyll.logger.info "CSV Validator:", "✓ Ошибок не найдено#{warnings.empty? ? '' : " (предупреждений: #{warnings.size})"}"
  else
    errors.each { |e| Jekyll.logger.error "CSV Validator Error:", e }
    Jekyll.logger.error "CSV Validator:", "✗ Найдено ошибок: #{errors.size}. Исправьте файл products.csv!"

    # Жёстко прерываем сборку — мусорные данные не должны попасть в деплой
    abort("Сборка остановлена из-за нарушения контракта данных в каталоге.")
  end
end
