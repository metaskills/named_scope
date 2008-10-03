
Factory.sequence(:id)     { |n| n }
Factory.sequence(:email)  { |n| "test_#{n}@domain.com" }
Factory.sequence(:report_title)  { |n| "Report Title ##{n}" }

Factory.define :employee do |e|
  e.name      { "Factory Employee ##{Factory.next(:id)}" }
  e.email     { Factory.next(:email) }
end

Factory.define :report do |r|
  r.title     { Factory.next(:report_title) }
  r.body      'Bla bla bla. Bla. Bla bla.'
end

Factory.define :employee_with_reports, :class => 'Employee' do |e|
  e.name      { "Factory Employee ##{Factory.next(:id)}" }
  e.email     { Factory.next(:email) }
  e.reports   { |employee| [employee.association(:report),employee.association(:report)] }
end

Factory.define :employee_with_urgent_reports, :class => 'Employee' do |e|
  e.name      { "Factory Employee ##{Factory.next(:id)}" }
  e.email     { Factory.next(:email) }
  e.reports   { |employee| [employee.association(:report), employee.association(:report,:title=>'URGENT'), 
                            employee.association(:report), employee.association(:report,:body=>'This is URGENT.')] }
end

