class UpdateAllAdvisorNamesAndDesignations < ActiveRecord::Migration[8.1]
  def up
    {
      "Lakshmi Kumar"        => { name: "Dr. Lakshmi Kumar",    title: "Director",                                                              organisation: "Avasara Academy" },
      "Parimal Merchant"     => { name: "Dr. Parimal Merchant", title: "Director - Global Family Managed Business",                             organisation: "SP Jain School of Global Management" },
      "Seetha Murty"         => { name: "Dr. Seetha Murty",     title: "President - Association for Heads of IB World Schools (India & South Asia)", organisation: "Association for Heads of IB World Schools" },
      "Alka Pandey"          => {                                title: "Academic Advisor - South Asia",                                        organisation: "Cambridge International" },
      "Dr. Sanjay Malpani"   => {                                title: "Chairman",                                                             organisation: "Dhruv Global School" },
      "Dr. Swati Popat Vats" => {                                title: "President",                                                            organisation: "ECA & Podar Education Network" },
      "Mrunal Shah"          => {                                title: "Founder & Play Expert",                                                organisation: "Sunday Bricks" },
      "Russell John Cailey"  => {                                title: "CEO & Founder",                                                        organisation: "Almach AI™" },
      "Kiran Bir Sethi"      => {                                title: "Founder",                                                              organisation: "The Riverside High School" },
    }.each do |current_name, attrs|
      sp = SummitSpeaker.find_by(name: current_name)
      sp&.update!(attrs)
    end
  end

  def down; end
end
