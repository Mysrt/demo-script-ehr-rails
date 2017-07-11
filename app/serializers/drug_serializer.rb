class DrugSerializer

  def initialize(drug)
    @drug = drug
  end

  def serialize!
    {
      ddid: "00228280311",
      description: "Spironolactone",
      quantity: 30,
      quantity_qualifier: "C48542",
      ndc: "00228280311",
      days_supply: 30,
    }.deep_stringify_keys!
  end

  alias :to_hash :serialize!

end
