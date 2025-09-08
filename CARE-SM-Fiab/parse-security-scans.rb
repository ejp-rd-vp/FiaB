require 'json'
require 'csv'

def parse_trivy_json(output)
  # Parse Trivy JSON output and filter for CRITICAL and HIGH vulnerabilities.
  # Expects JSON with a 'Results' key containing an array of result objects.
  begin
    data = JSON.parse(output)
    filtered_vulns = []
    results = data['Results'] || []
    unless data['Results']
      return nil, 'JSON does not contain "Results" key. Ensure input is valid Trivy JSON output.'
    end
    results.each do |result|
      next unless result['Vulnerabilities'] # Skip if no vulnerabilities
      result['Vulnerabilities'].each do |vuln|
        severity = vuln['Severity']&.upcase
        if %w[CRITICAL HIGH].include?(severity)
          filtered_vulns << {
            'Target' => result['Target'] || 'Unknown',
            'VulnerabilityID' => vuln['VulnerabilityID'] || 'N/A',
            'PkgName' => vuln['PkgName'] || 'N/A',
            'InstalledVersion' => vuln['InstalledVersion'] || 'N/A',
            'FixedVersion' => vuln['FixedVersion'] || 'N/A',
            'Severity' => severity,
            'Title' => vuln['Title'] || 'N/A',
            'PrimaryURL' => vuln['PrimaryURL'] || 'N/A'
          }
        end
      end
    end
    [filtered_vulns, nil]
  rescue JSON::ParserError
    [nil, 'Invalid JSON format. Ensure input is valid Trivy JSON output.']
  end
end

def write_csv_output(vulns, output_file)
  # Write filtered vulnerabilities to a CSV file for spreadsheet use.
  if vulns.empty?
    return "No CRITICAL or HIGH vulnerabilities found. No CSV file created for #{output_file}."
  end

  headers = ['Target', 'VulnerabilityID', 'Package', 'InstalledVersion', 'FixedVersion', 'Severity', 'Title', 'PrimaryURL']
  CSV.open(output_file, 'w') do |csv|
    csv << headers
    vulns.each do |vuln|
      csv << [
        vuln['Target'],
        vuln['VulnerabilityID'],
        vuln['PkgName'],
        vuln['InstalledVersion'],
        vuln['FixedVersion'],
        vuln['Severity'],
        vuln['Title'],
        vuln['PrimaryURL']
      ]
    end
  end

  critical_count = vulns.count { |v| v['Severity'] == 'CRITICAL' }
  high_count = vulns.count { |v| v['Severity'] == 'HIGH' }
  "Generated CSV file '#{output_file}' with #{vulns.length} vulnerabilities (CRITICAL: #{critical_count}, HIGH: #{high_count})."
end

# Check for valid input
if ARGV.empty?
  puts 'Usage: ruby trivy_parser.rb <trivy_output.json> [trivy_output2.json ...] or glob pattern (e.g., ./scans/*.json)'
  exit 1
end

# Process all files matching the provided arguments (supports glob patterns)
files = ARGV.flat_map { |arg| Dir.glob(arg) }.uniq
if files.empty?
  puts 'Error: No JSON files found matching the provided pattern(s).'
  exit 1
end

files.each do |file|
  puts "\nProcessing #{file}..."
  begin
    output = File.read(file)
  rescue Errno::ENOENT
    puts "Error: File '#{file}' not found."
    next
  end

  # Parse JSON
  vulns, error = parse_trivy_json(output)
  if error
    puts "Error for #{file}: #{error}"
    next
  end

  # Generate output CSV filename (replace .json with .csv)
  output_file = File.join(File.dirname(file), File.basename(file, '.json') + '.csv')

  # Write CSV and print result
  puts write_csv_output(vulns, output_file)
end
