# Source of tenders, in simple - site
# where tenders are published
class Source
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :tenders
  has_many :selectors
  has_many :cartridges

  # Source info
  field :name, type: String
  field :url, type: String
  field :comment, type: String

  # Service parameters
  field :is_active, type: Boolean
  field :last_imported_at, type: DateTime
  field :source_type, type: Symbol, default: :auto

  # Resque parameters
  field :resque_frequency, type: Integer
  field :deep_level, type: Integer, default: 100
  field :priority, type: Symbol, default: :normal

  # Field used for invoking pre and post processing of data or parametres
  # Example
  # { :class_name => 'ZakupkiTrigger', :before => false, :after => true }
  field :trigger, type: Hash, default: { class_name: "", before: false, after: false }

  # Example of proxy_update_frequency field value
  # This
  # { "type":"hits","value":"100" }
  # means what every 100 hits we must change proxy server
  # Another form
  # { "type":"time", "value":"5.minutes" }
  # means what every 5 minutes we also must change proxy server
  field :proxy_update_frequency, type: Hash, default: { "type" => "time", "value" => 0 }

  # Statistic tenders count
  field :tenders_count, type: Integer
  field :construction_tenders_count, type: Integer

  scope :active, -> { where(:is_active => true) }

  def load_cartridges
    cartridges.active.to_a
  end
end
