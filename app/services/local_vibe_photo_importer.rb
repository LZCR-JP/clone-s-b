require "json"
require "fileutils"
require "digest"

class LocalVibePhotoImporter
  DATA_DIR = Rails.root.join("db/vibe_cards/local_photos")
  OUTPUT_DIR = Rails.root.join("public/vibe_cards/local_prototype")
  FIELDS = %w[title description image_type cuisine source_key min_budget max_budget min_group_size max_group_size
              vibe_scores].freeze
  TYPES = %w[food venue people].freeze
  SCORE_KEYS = %w[luxury casual lively modern privacy traditional cozy outdoor].freeze

  def initialize(write: false, activate: false, include_reserve: false)
    @write = write
    @activate = activate
    @include_reserve = include_reserve
  end

  def call
    raise "Local development only; photo reuse rights have not been verified" unless Rails.env.development?
    raise "ACTIVATE requires WRITE=1" if @activate && !@write

    missing = FIELDS - VibeCard.column_names
    raise "Run rails db:migrate first; missing: #{missing.join(', ')}" if missing.any?

    rows = JSON.parse(File.read(DATA_DIR.join("manifest.json")))
    raise "Invalid manifest" unless rows.is_a?(Array)

    rows = rows.select do |r|
      r.fetch("review_status") == "recommended" || (@include_reserve && r.fetch("review_status") == "reserve")
    end
    raise "No selected cards" if rows.empty?
    raise "Duplicate photo key" unless rows.map { |r| r.fetch("source_key") }.uniq.size == rows.size
    raise "Duplicate filename" unless rows.map { |r| r.fetch("filename") }.uniq.size == rows.size

    prepared = rows.map do |row|
      filename = row.fetch("filename")
      raise "Invalid filename: #{filename}" unless filename.match?(/\A[0-9]+-[a-z0-9-]+\.jpg\z/)
      raise "Invalid source key" unless row.fetch("source_key").match?(/\Alocal-[0-9a-f]{24}\z/)
      raise "Invalid image type" unless TYPES.include?(row.fetch("image_type"))

      scores = row.fetch("vibe_scores")
      raise "Invalid scores: #{filename}" unless scores.is_a?(Hash) && scores.all? do |k, v|
        SCORE_KEYS.include?(k) && v.is_a?(Integer) && v.between?(0, 100)
      end

      source = DATA_DIR.join("images", filename)
      target = OUTPUT_DIR.join(filename)
      raise "Missing image: #{source}" unless File.file?(source) && File.size?(source)
      if target.exist? && Digest::SHA256.file(source).hexdigest != Digest::SHA256.file(target).hexdigest
        raise "Refusing to overwrite different image: #{target}"
      end

      card = VibeCard.find_or_initialize_by(source_key: row.fetch("source_key"))
      card.assign_attributes(row.slice(*FIELDS).merge("image_url" => "/vibe_cards/local_prototype/#{filename}"))
      # A re-import never deactivates a previously active card.
      card.active = @activate || (!card.new_record? && card.active?)
      raise "#{filename}: #{card.errors.full_messages.join(', ')}" unless card.valid?

      [card, source, target]
    end

    prepared.group_by { |card, _, _| card.image_type }.each { |kind, items| puts "  #{kind}: #{items.size}" }
    return prepared.size unless @write

    created_files = []
    begin
      FileUtils.mkdir_p(OUTPUT_DIR)
      VibeCard.transaction do
        prepared.each do |card, source, target|
          unless target.exist?
            created_files << target
            FileUtils.cp(source, target)
          end
          card.save!
        end
      end
    rescue StandardError
      created_files.each { |path| FileUtils.rm_f(path) }
      raise
    end
    prepared.size
  end
end
