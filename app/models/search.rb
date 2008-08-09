class Search < ActiveRecord::BaseWithoutTable
  column :q, :string
  column :action_type, :string
  column :created, :integer
  attr_accessor :sites, :kind, :ip_address
  
  validates_inclusion_of :created, :in => %w{ 30 14 7 2 1 }
  
  Ultrasphinx::Search.excerpting_options = HashWithIndifferentAccess.new({
    :before_match => '<strong style="color:red">',
    :after_match => '</strong>',
    :chunk_separator => "...",
    :limit => 1024,
    :around => 3,
    :content_methods => [['title'],['description']]
  })

  def results(page)
    if kind == 'map'
      @search = Action.find(:all, :origin => [current_latitude, current_longitude], :conditions => build_conditions)
    else
      #Action.paginate(:all, :page => page, :order => build_order, :conditions => build_conditions)
      # TODO figure out random for sort_by, figure out filter by created_at > created.days.ago
      @search = Ultrasphinx::Search.new(
                :query => build_query,
                :per_page => 10,
                :page => page || 1,
                :sort_mode => 'descending',
                :sort_by => 'created_at',
                :filters => build_filters,
                :facets => ['action_type']
                #, :weights => {}
      )
      #TODO do we want excerpt to be conditional in whether we're on web site or not?
      @search.excerpt
      @search.results
    end
  end
  
  def paginate_object
    @search
  end
  
  def to_s
    output = []
    output << "Query: #{q}" if q?
    output << "Created: #{created}" if created?
    output << "Action Type: #{action_type}" if action_type?
    output.join(', ')
  end
  
  def build_query
    unless action_type.nil? or action_type == 'all'
      "action_type:\"#{action_type}\" AND (#{q})"
    else
      q  
    end
  end
  
  def build_filters
    unless sites.length == 0
      {'site_id' => sites}
    else
      {}
    end
  end

  def build_conditions
    reset_conditions
    add_q
    add_action_type
    add_sites
    add_created
    add_mapping
    conditions.join(' AND ')
  end
  
  def build_order
    kind == 'random' ? 'RAND()' : 'created_at DESC'
  end
  
  def sites
    @sites ||= []
  end

  def has_site?(site)
    return true if sites.empty?
    sites.include?(site.id.to_s)
  end

  def reset_conditions
    @conditions = []
  end

  def conditions
    @conditions ||= []
  end

  def add_q
    unless q.nil? or q.empty?
      keyword_conditions = []
      q.split(' ').each do |keyword|
        keyword_conditions << sanitize(["(description LIKE ? OR title LIKE ?)", "%#{keyword}%", "%#{keyword}%"])
      end
      conditions << "(" + keyword_conditions.join(' OR ') + ")"
    end
  end
  
  def add_action_type
    unless action_type.nil? or action_type == 'all'
      conditions << "action_type = '#{action_type}'"
    end
  end
  
  def add_sites
    unless sites.nil? or sites.empty?
      conditions << sanitize(["site_id IN (?)", sites])
    end
  end
  
  def add_created
    unless created.nil?
      conditions << sanitize(["actions.created_at > ?", created.days.ago])
    end
  end
  
  def add_mapping
    if kind == 'map'
      conditions << 'latitude IS NOT NULL and longitude IS NOT NULL'
    end
  end
  
  def sanitize(arg)
    ActiveRecord::Base.send(:sanitize_sql, arg)
  end
  
  def current_latitude
    current_location.lat || 21.98
  end
  
  def current_longitude
    current_location.lng || -10.00
  end
  
  def current_location
    # debugger
    @current_location ||= GeoKit::Geocoders::IpGeocoder.geocode(current_ip)
  end
  
  def current_ip
    ip_address == '127.0.0.1' ? '67.162.124.13' : ip_address
  end
  
  # def get_current_location
  #   location = GeoKit::Geocoders::IpGeocoder.geocode(request.remote_ip)
  #   unless location.lat.nil? and location.lng.nil?
  #     return location.lat, location.lng
  #   else
  #     return 41.98, -87.90 # Chicago, an estimate
  #   end
  # end
  
end
