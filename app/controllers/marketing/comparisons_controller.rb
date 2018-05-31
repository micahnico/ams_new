module Marketing
  class ComparisonsController < BaseController
    def index
      @prospect = Prospect.find(params[:prospect_id])
      @statement = @prospect.statements.find(params[:statement_id])

      load_qualified_programs(@statement)

      @comparisons = []
        @programs.each do |program|
          @comparison = Comparison.new
          set_comparison_references(@comparison, @statement, program)
          set_all_custom_field_c_values_to_zero(@comparison)
          set_custom_fields(        @comparison, @statement, program)
          set_other_fees(           @comparison, @statement, program)
          set_vmd_per_item_fees(    @comparison, @statement, program.min_per_item_fee)
          set_vmd_mark_up(          @comparison, @statement, program.min_bp_mark_up)
          set_vmd_access_fees(      @comparison, @statement)
          set_amex_fees(            @comparison, @statement)
          set_debit_fees(           @comparison, @statement)
          set_total_fees(           @comparison, @statement, program)
          set_vmd_costs(            @comparison, @statement, program)
          set_amex_costs(           @comparison, @statement, program)
          set_debit_costs(          @comparison, @statement, program)
          set_other_costs(          @comparison, @statement, program)
          set_total_costs(          @comparison, @statement, program)
          set_compensation(         @comparison, program)
          set_conditional_savings(  @comparison, @statement)
          set_fixed_values(         @comparison)

          @comparison.save
          @comparisons << @comparison
      end
      redirect_to marketing_prospect_statement_comparison_path(@prospect, @statement, @comparisons[0])
    end

    def show
      @comparison = Comparison.find(params[:id])
      @program = Program.find_by_id(@comparison.program_id)
      @statement = Statement.find_by_id(@comparison.statement_id)
      @prospect = Prospect.find(@statement.prospect_id)
      @algorithm = Algorithm.new(@statement, @prospect)
      @inttableitems = @algorithm.calculate
      @statement.presented_program = @program.name
      @statement.save
      respond_to do |format|
        format.html
      end
    end

    def savings_detail
      @comparison = Comparison.find(params[:comparison_id])
      @statement = Statement.find(params[:statement_id])
      @prospect = Prospect.find(params[:prospect_id])
      respond_to do |format|
      format.pdf do
          pdf = DetailPdf.new(@prospect, @statement, @comparison, view_context, current_user)
          send_data pdf.render, filename: "#{@prospect.business_name} Proposal.pdf",
                                type: "application/pdf",
                                disposition: "inline"
        end
      end
    end

    private

    def load_qualified_programs(s)
      @all_programs = Program.all
      @programs = []
      @all_programs.each do |program|
        @min = program.min_volume
        if program.max_volume > 0
          @max = program.max_volume
        else
          @max = 10000000
        end
        @vol = s.vmd_vol
        if @min < @vol && @max > @vol
        @programs << program
      end
    end
  end

    def set_comparison_references(c, s, p)
      c.statement_id = s.id
      c.program_id = p.id
    end

    def set_other_fees(c, s, p)
        c.vs_access_per_item_fee = p.visa_access_per_item
        c.vs_access_percentage_fee = p.visa_access_percentage
        c.mc_access_per_item_fee = p.mc_access_per_item
        c.mc_access_percentage_fee = p.mc_access_percentage
        c.ds_access_per_item_fee = p.disc_access_per_item
        c.ds_access_percentage_fee = p.disc_access_percentage
        c.monthly_pci_fee = p.monthly_pci_fee
        c.annual_pci_fee = p.annual_pci_fee
        c.pin_debit_per_item_fee = p.min_pin_debit_per_item_fee
        c.pin_debit_bp_mark_up = 0
        c.monthly_debit_fee = p.min_monthly_debit_fee
        c.next_day_funding_fee = p.next_day_funding_monthly_fee
        c.amex_per_item_fee = p.min_amex_per_item_fee
        c.amex_bp_mark_up = p.min_amex_bp_fee
        c.amex_per_item_cost = s.amex_per_item_cost
        c.amex_percentage_cost = s.amex_percentage_cost
        c.application_fee = p.min_application_fee
        c.per_batch_fee = p.min_per_batch_fee
        c.batch_fees = (
          s.batches *
          p.min_per_batch_fee )
        c.monthly_pci_fees = p.monthly_pci_fee
        c.annual_pci_fees = p.annual_pci_fee
        c.monthly_fees = p.min_monthly_fees
        c.annual_fee = 0
    end

    def set_vmd_per_item_fees(c, s, per_item_fee)
      c.per_item_fee = per_item_fee.round(2)

      c.vs_trans_fees = (
        s.vs_transactions *
        per_item_fee )

      c.mc_trans_fees = (
        s.mc_transactions *
        per_item_fee )

      c.ds_trans_fees = (
        s.ds_transactions *
        per_item_fee )

      c.total_vmd_trans_fees = (
        c.vs_trans_fees +
        c.mc_trans_fees +
        c.mc_trans_fees )
    end

    def set_vmd_mark_up(c, s, bp_mark_up)
      c.bp_mark_up = bp_mark_up

      c.vs_mark_up_fees = (
        s.vs_volume *
        (c.bp_mark_up.to_f / 10000 ) )

      c.mc_mark_up_fees = (
        s.mc_volume *
        (c.bp_mark_up.to_f / 10000 ) )

      c.ds_mark_up_fees = (
        s.ds_volume *
        (c.bp_mark_up.to_f / 10000 ) )

      c.total_vmd_mark_up_fees = (
        c.vs_mark_up_fees +
        c.mc_mark_up_fees +
        c.ds_mark_up_fees )
    end

    def set_vmd_access_fees(c, s)
      c.vs_access_per_item_fees = (
        c.vs_access_per_item_fee *
        s.vs_transactions )

      c.mc_access_per_item_fees = (
        c.mc_access_per_item_fee *
        s.mc_transactions )

      c.ds_access_per_item_fees = (
        c.ds_access_per_item_fee *
        s.ds_transactions )

      c.vs_access_percentage_fees = (
        ( c.vs_access_percentage_fee.to_f / 10000 ) *
        s.vs_volume )

      c.mc_access_percentage_fees = (
        ( c.mc_access_percentage_fee.to_f / 10000 ) *
        s.mc_volume )

      c.ds_access_percentage_fees = (
        ( c.ds_access_percentage_fee.to_f / 10000 ) *
        s.ds_volume )

      c.total_vs_access_fees = (
        c.vs_access_per_item_fees +
        c.vs_access_percentage_fees )

      c.total_mc_access_fees = (
        c.mc_access_per_item_fees +
        c.mc_access_percentage_fees )

      c.total_ds_access_fees = (
        c.ds_access_per_item_fees +
        c.ds_access_percentage_fees )

      c.total_vmd_access_fees = (
        c.total_vs_access_fees +
        c.total_mc_access_fees +
        c.total_ds_access_fees )
    end

    def set_amex_fees(c, s)
      c.amex_mark_up_fees = (
        s.amex_vol *
        ( c.amex_bp_mark_up.to_f / 10000 ) )

      c.amex_trans_fees = (
        s.amex_trans *
        c.amex_per_item_fee )

      c.amex_total_opt_blue = (
        (c.amex_per_item_cost * s.amex_trans) +
        (s.amex_vol * (c.amex_percentage_cost / 100)))
    end

    def set_debit_fees(c, s)
      c.debit_trans_fees = (
      s.debit_trans *
      c.pin_debit_per_item_fee )

      if s.debit_trans > 0
        c.total_debit_fees = (
        c.debit_trans_fees +
        c.monthly_debit_fee)
      else
        c.total_debit_fees = 0
      end
    end

     def set_total_fees(c, s, p)
      c.total_program_fees = (
      c.monthly_fees +
      c.monthly_pci_fees +
      ( c.annual_pci_fees / 12 ) +
      ( c.annual_fee / 12 ) +
      s.interchange +
      c.total_vmd_mark_up_fees +
      c.batch_fees +
      c.amex_mark_up_fees +
      c.total_vmd_trans_fees +
      c.amex_trans_fees +
      c.total_vmd_access_fees +
      c.total_debit_fees +
      c.custom_monthly_fees +
      (c.custom_annual_fees / 12) +
      c.custom_total_vmd_per_item_fees +
      c.custom_total_vmd_volume_bp_fees +
      c.custom_total_amex_per_item_fees +
      c.custom_total_amex_volume_bp_fees +
      c.custom_total_pin_per_item_fees +
      c.custom_total_pin_volume_bp_fees)
    end

    def set_vmd_costs(c, s, p)
      c.bin_fee_costs = (
        ( s.vmd_vol * (p.bin_sponsorship.to_f / 10000) ) +
        c.custom_vmd_volume_bp_costs )

      c.vs_trans_fee_costs = (
        s.vs_transactions *
        p.per_item_cost )

      c.mc_trans_fee_costs = (
        s.mc_transactions *
        p.per_item_cost )

      c.ds_trans_fee_costs = (
        s.ds_transactions *
        p.per_item_cost )

      c.total_vmd_trans_fee_costs = (
        c.ds_trans_fee_costs +
        c.mc_trans_fee_costs +
        c.vs_trans_fee_costs +
        c.custom_vmd_per_item_fee_costs)
    end

    def set_amex_costs(c, s, p)
      c.amex_per_item_costs = (
        (s.amex_trans * p.amex_per_item_cost ) +
        c.custom_amex_per_item_costs)
      if s.amex_trans > 0
      c.amex_mark_up_costs = (
        (s.amex_vol * (p.amex_bp_cost.to_f / 10000 ) ) +
         c.custom_amex_volume_bp_costs)
      else
        c.amex_mark_up_costs = 0
      end
    end

    def set_debit_costs(c, s, p)
      c.debit_per_item_costs = (
        (s.debit_trans * p.pin_debit_per_item_cost ) +
        c.custom_pin_per_item_costs)

        if s.debit_trans > 0
          c.total_debit_costs = (
          c.debit_per_item_costs +
          p.monthly_debit_fee_cost +
          c.custom_pin_volume_bp_costs )
        else
          c.total_debit_costs = 0
        end
    end

    def set_other_costs(c, s, p)
      c.batch_fee_costs = (
        s.batches *
        p.per_batch_cost )
    end

    def set_total_costs(c, s, p)
      c.total_program_costs = (
        c.batch_fee_costs +
        c.bin_fee_costs +
        c.total_vmd_trans_fee_costs +
        c.amex_per_item_costs +
        c.amex_mark_up_costs +
        c.total_debit_costs +
        s.interchange +
        p.monthly_fee_costs +
        p.monthly_pci_cost +
        ( p.annual_pci_cost / 12 ) +
        c.custom_monthly_fee_costs +
        (c.custom_annual_fee_costs / 12 ) )
    end

    def set_compensation(c, p)
      c.total_program_residuals = (
      ( c.total_program_fees -
        c.total_program_costs ) *
      ( p.residual_split.to_f / 100 ) )

      c.total_program_bonus =
        p.up_front_bonus +
        (c.custom_sales_bonus - c.custom_sales_bonus_costs)
      if c.application_fee > 0
        c.total_program_bonus += (c.application_fee - p.application_fee_cost)
      end
      if c.custom_one_time_fee > 0
        c.total_program_bonus += (c.custom_one_time_fee - c.custom_one_time_fee_costs)
      end
    end

    def set_fixed_values(c)
      c.gross_margin_fixed = (
        c.total_program_savings +
        ( c.total_program_fees -
          c.total_program_costs ) )

      c.savings_fixed = c.total_program_savings
    end

    def set_conditional_savings(c, s)
       if s.total_fees > 0
            set_total_savings(c, s)
          else
            c.total_program_savings = 0
          end
    end

    def set_total_savings(c, s)
        c.total_program_savings = (
          s.total_fees -
          c.total_program_fees )

        c.total_program_savings = c.total_program_savings.round(0)

        if c.total_program_savings < 0 && c.total_program_savings > -0.01
          c.total_program_savings = 0
        end
    end

    def set_per_item_change(c, s)
      @change = (c.savings_fixed * 0.2 )
      @per_item_change = ( ( @change * 0.5 ) / s.vmd_trans )

      if @per_item_change > 0.02
          @per_item_change = 0.02
      end
    end

    def set_bp_change(c, s, per_item_change)
      @change = (c.savings_fixed * 0.2 )
      @bp_change = (
        @change -
        ( per_item_change *
          @statement.vmd_trans ) )

      @basis_points = (
        ( @bp_change /
          s.vmd_vol ) * 10000 )
    end

      def set_custom_fields(c, s, p)
      @custom_fields = CustomField.where(program_id: p.id)
      if @custom_fields.first != nil

        @custom_fields.each do |field|
          @custom_field_type = CustomFieldType.find_by_id(field.custom_field_type_id)
          @slug_string = @custom_field_type.slug_string

          case @slug_string

          when "monthly_fee"
            c.custom_monthly_fees += field.amount
            c.custom_monthly_fee_costs += field.cost
          when "annual_fee"
            c.custom_annual_fees += field.amount
            c.custom_annual_fee_costs += field.cost
          when "vmd_per_item"
            c.custom_vmd_per_item_fee += field.amount
            c.custom_vmd_per_item_fee_cost += field.cost
          when "vmd_volume_bp"
            c.custom_vmd_volume_bp += field.amount
            c.custom_vmd_volume_bp_cost += field.cost
          when "amex_per_item"
            c.custom_amex_per_item += field.amount
            c.custom_amex_per_item_cost += field.cost
          when "amex_volume_bp"
            c.custom_amex_volume_bp += field.amount
            c.custom_amex_volume_bp_cost += field.cost
          when "pin_per_item"
            c.custom_pin_per_item += field.amount
            c.custom_pin_per_item_cost += field.cost
          when "pin_volume_bp"
            c.custom_pin_volume_bp += field.amount
            c.custom_pin_volume_bp_cost += field.cost
          when "sales_bonus"
            c.custom_sales_bonus += field.amount
            c.custom_sales_bonus_costs += field.cost
          when "one_time_fee"
            c.custom_one_time_fee += field.amount
            c.custom_one_time_fee_costs += field.cost
          end
        end
        if c.custom_vmd_per_item_fee > 0
          c.custom_total_vmd_per_item_fees = (s.vmd_trans * c.custom_vmd_per_item_fee)
          c.custom_vmd_per_item_fee_costs = (s.vmd_trans * c.custom_vmd_per_item_fee_cost)
        end
        if c.custom_vmd_volume_bp > 0
          c.custom_total_vmd_volume_bp_fees = (s.vmd_vol * ( c.custom_vmd_volume_bp.to_f / 10000 ) )
          c.custom_vmd_volume_bp_costs = (s.vmd_vol * ( c.custom_vmd_volume_bp_cost.to_f / 10000 ) )
        end
        if c.custom_amex_per_item > 0
          c.custom_total_amex_per_item_fees = (s.amex_trans * c.custom_amex_per_item)
          c.custom_amex_per_item_costs = (s.amex_trans * c.custom_amex_per_item_cost)
        end
        if c.custom_amex_volume_bp > 0
          c.custom_total_amex_volume_bp_fees = (s.amex_vol * ( c.custom_amex_volume_bp.to_f / 10000 ) )
          c.custom_amex_volume_bp_costs = (s.amex_vol * ( c.custom_amex_volume_bp_cost.to_f / 10000 ) )
        end
        if c.custom_pin_per_item > 0
          c.custom_total_pin_per_item_fees = (s.debit_trans * c.custom_pin_per_item)
          c.custom_pin_per_item_costs = (s.debit_trans * c.custom_pin_per_item_cost)
        end
        if c.custom_pin_volume_bp > 0
          c.custom_total_pin_volume_bp_fees = (s.debit_vol * ( c.custom_pin_volume_bp.to_f / 10000 ) )
          c.custom_pin_volume_bp_costs = (s.debit_vol * ( c.custom_pin_volume_bp_cost.to_f / 10000 ) )
        end
      end
    end

    def set_all_custom_field_c_values_to_zero(c)
      c.custom_monthly_fees = 0
      c.custom_monthly_fee_costs = 0
      c.custom_annual_fees = 0
      c.custom_annual_fee_costs = 0
      c.custom_vmd_per_item_fee = 0
      c.custom_vmd_per_item_fee_cost = 0
      c.custom_vmd_volume_bp = 0
      c.custom_vmd_volume_bp_cost = 0
      c.custom_amex_per_item = 0
      c.custom_amex_per_item_cost = 0
      c.custom_amex_volume_bp = 0
      c.custom_amex_volume_bp_cost = 0
      c.custom_pin_per_item = 0
      c.custom_pin_per_item_cost = 0
      c.custom_pin_volume_bp = 0
      c.custom_pin_volume_bp_cost = 0
      c.custom_sales_bonus = 0
      c.custom_sales_bonus_costs = 0
      c.custom_one_time_fee = 0
      c.custom_one_time_fee_costs  = 0
      c.custom_total_vmd_per_item_fees = 0
      c.custom_vmd_per_item_fee_costs = 0
      c.custom_total_vmd_volume_bp_fees = 0
      c.custom_vmd_volume_bp_costs = 0
      c.custom_total_amex_per_item_fees = 0
      c.custom_amex_per_item_costs = 0
      c.custom_total_amex_volume_bp_fees = 0
      c.custom_amex_volume_bp_costs = 0
      c.custom_total_pin_per_item_fees = 0
      c.custom_pin_per_item_costs = 0
      c.custom_total_pin_volume_bp_fees = 0
      c.custom_pin_volume_bp_costs = 0
    end

  end
end