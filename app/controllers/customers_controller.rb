class CustomersController < ApplicationController
  require 'rubyXL/convenience_methods'
  require 'zip'
  require 'fileutils'
  require 'rubygems'
  require "prawn/table"
  require "prawn"
  require 'date'
  def index
    @user = User.find(current_user.id)
  end

  def show

    @customer = Customer.find(params[:id])
    if @customer.user.id != current_user.id
      redirect_to customers_path, alert: '不正なアクセスです' 
    end

  
  end

  def new
    @customer = Customer.new
   
  end


  def create
    

    respond_to do |format|
      format.html do
        @customer = Customer.new(customer_params)
        @customer.user_id = current_user.id
        @customer.save
        redirect_to customers_path
      end

      format.pdf do
        dt = DateTime.now
        @user = User.find(current_user.id)
        @customers = @user.customers


        @customers.each do |customer|
          filename=dt.strftime('%Y%m%d')+'請求書_'+customer.name+'様.pdf'

        pdf = Prawn::Document.new(:page_size=> 'A4',
          :left_margin=>100,
          :right_margin=>100)
          # pdf.stroke_axis
          pdf.font_families.update('Test' => { normal:  "app/assets/genshingothic-20150607/GenShinGothic-P-Light.ttf", bold: 'app/assets/genshingothic-20150607/GenShinGothic-Bold.ttf' })
          pdf.font 'Test'
          pdf.move_down 65
          pdf.text "請求書" ,size: 13.3,style: :bold
          dt = DateTime.now
          pdf.text_box '請求日：', size: 5.7,:width=>58.363,:at=>[257.329,684],:align=>:left
          pdf.text_box '請求番号：', size: 5.7,:width=>58.363,:at=>[257.329,674],:align=>:left
          pdf.text_box @user.company, size: 5.7,:width=>58.363,:at=>[257.329,654],:align=>:left
          pdf.text_box 'MAIL：', size: 5.7,:width=>58.363,:at=>[257.329,644],:align=>:left
          pdf.text_box '担当：', size: 5.7,:width=>58.363,:at=>[257.329,634],:align=>:left
          pdf.text_box dt.strftime("%Y/%m/%d"), size: 5.7,:width=>79.587,:at=>[315.692,684],:align=>:right
          pdf.text_box customer.code+'-'+dt.strftime("%Y%m%d"), size: 5.7,:width=>79.587,:at=>[315.692,674],:align=>:right
          pdf.text_box @user.email, size: 5.7,:width=>79.587,:at=>[315.692,644],:align=>:left
          pdf.text_box @user.username, size: 5.7,:width=>79.587,:at=>[315.692,634],:align=>:left
          pdf.move_down 36
          pdf.text customer.name + ' 御中',size: 5.7
          pdf.move_down 2
          pdf.stroke_horizontal_line 0,180
          pdf.move_down 2
          pdf.text 'ご担当            '+customer.manager + ' 様',size: 5.7
          pdf.move_down 36
          pdf.text '下記の通りご請求申し上げます。',size: 5.7
          pdf.move_down 5
          deals_list = [
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','',''],
            ['','','','','']
          ]
          total=0
          customer.deals.each_with_index do |deal,index|
            deals_list[index][0]=index+1
            deals_list[index][1]=deal.title
            deals_list[index][2]=deal.amount
            deals_list[index][3]=deal.price
            subtotal=deal.amount*deal.price
            total += subtotal
            deals_list[index][4]='¥'+subtotal.to_s(:delimited)
          end
          tax =total/10.floor
          payment = total+tax 
          pdf.text '合計金額' ,size: 5.7
          pdf.text_box '¥'+payment.to_s(:delimited), size: 9,:width=>61.016,style: :bold,:at=>[196.313,593],:align=>:right
          pdf.move_down 4
          pdf.stroke_horizontal_line 0,257.329
          pdf.move_down 2
          pdf.text 'お支払い期限',size: 5.7
          next_month = Time.now.month+1
          pdf.text_box Date.new(Time.now.year+next_month.div(12),next_month.modulo(12),-1).strftime("%Y/%m/%d"), size: 5.7,:width=>61.016,:at=>[196.313,579],:align=>:right
          pdf.move_down 12.25
          pdf.table([['No','品目名','数量','単価','金額']],column_widths: [43.507,152.806,61.016,58.363,79.588],position: :center,:cell_style => {
            :inline_format => true,
            :padding => [0.8, 0,0,0], :size =>10,
            :border_widths => [1, 0.5, 1, 0.5],
            :height => 9.65,
        }) do |t|
            t.rows(0).style :align=>:center
            t.cells.size = 5.7
            t.columns(0).border_widths = [1,0.5,1,1]
          end
          pdf.table(deals_list,column_widths: [43.507,152.806,61.016,58.363,79.587],position: :center,:cell_style => {
            :inline_format => true,
            :padding => [0.8, 2,0,2], 
            :border_widths => [0.5, 0.5, 0.5, 0.5],
            :height => 9.65,
        }) do |k|
            k.columns(1).style :align => :left
            k.columns([2,3,4]).style :align => :right
            k.columns(0).style :align => :center
            k.cells.size = 5.7
            k.columns(0).border_widths = [0.5,0.5,0.5,1]
            k.columns(-1).border_widths = [0.5,1,0.5,0.5]
            k.rows(-1).border_widths = [0.5,0.5,1,0.5]
            k.columns(0).rows(-1).border_widths = [0.5,0.5,1,1]
            k.columns(-1).rows(-1).border_widths = [0.5,1,1,0.5]
          end
          total_table=[['小計','¥'+total.to_s(:delimited)],['消費税','¥'+tax.to_s(:delimited)],['合計','¥'+payment.to_s(:delimited)]]
          pdf.table(total_table,column_widths: [58.363,79.587],position: :right,:cell_style => {
            :inline_format => true,
            :padding => [0.8, 2,0,0], 
            :border_widths => [0.5, 0.5, 0.5, 0.5],
            :height => 9.65,
        }) do |k|
            k.columns(1).style :align => :right
            k.columns(0).style :align => :center
            k.cells.size = 5.7
            k.columns(0).border_widths = [0.5,0.5,0.5,1]
            k.columns(-1).border_widths = [0.5,1,0.5,0.5]
            k.rows(-1).border_widths = [0.5,0.5,1,0.5]
            k.columns(0).rows(-1).border_widths = [0.5,0.5,1,1]
            k.columns(-1).rows(-1).border_widths = [0.5,1,1,0.5]
          end
          pdf.move_down 9.65
          pdf.bounding_box([0,297.5],:width=>43.507,:height=>9.65){
            pdf.stroke_bounds
            pdf.draw_text "振込先",:at =>[2,3],size: 5.7,valign: :center
          }
          pdf.bounding_box([0,287.85],:width=>395.279,:height=>57.9){
            pdf.stroke_bounds
            @user.account.each_line.with_index  do |str,index|
              pdf.draw_text str.chomp,:at =>[2,51.25-9.65*index],size: 5.7,valign: :top 
            end
          }
          pdf.bounding_box([0,212],:width=>43.507,:height=>9.65){
            pdf.stroke_bounds
            pdf.draw_text "備考",:at =>[2,3],size: 5.7,valign: :center
          }
          pdf.bounding_box([0,202.35],:width=>395.279,:height=>19.3){
            pdf.stroke_bounds
            pdf.draw_text '恐れ入りますが振り込み手数料は貴社にてご負担いただきますよう、お願い申し上げます。',:at =>[2,12.65],size: 5.7,valign: :top 
          }
  
        
            # app/assetsの下にtemplate.xlsxを配置した場合
          

          folder = "app/assets/books"
          pdf.render_file File.join(folder, filename)
          @zipfile_name = "app/assets/books/invoice.zip"
          Zip::File.open(@zipfile_name, Zip::File::CREATE) do |zipfile|
              zipfile.add(filename, File.join(folder, filename))
          end
          FileUtils.rm(File.join(folder, filename))
        end

# 送信
        send_data(File.read(@zipfile_name), filename: dt.strftime('%Y%m%d')+"_請求書pdf.zip")
        File.delete(@zipfile_name)
      end
      

      format.xlsx do
        dt = DateTime.now

        # def bulkcsv
        #   filename = "csv_archive.zip"
        #   fullpath = "#{Rails.root}/tmp/#{filename}"
        #   Zip::File.open(fullpath, Zip::File::CREATE) do |zipfile|
        #     zipfile.get_output_stream("csv/aaa.csv") do |f|
        #       f.puts(
        #         CSV.generate(encoding: Encoding::SJIS) do |csv|
        #           csv << %w(aaa1 aaa2 aaa3)
        #           csv << %w(101 102 103)
        #           csv << %w(201 202 203)
        #         end
        #       )
        #     zipfile.get_output_stream("csv/bbb.csv") do |f|
        #       f.puts(
        #         CSV.generate(encoding: Encoding::SJIS) do |csv|
        #           csv << %w(bbb1 bbb2 bbb3)
        #           csv << %w(101 102 103)
        #           csv << %w(201 202 203)
        #         end
        #       )
        #     end
        #   end
        #   # zipをダウンロードして、直後に削除する
        #   send_data File.read(fullpath), filename: filename, type: 'application/zip'
        #   File.delete(fullpath)
        # end
       
    # @deals = Deal.where(customer_id: params[:customer_id]) 
        @user = User.find(current_user.id)
        @customers = @user.customers
  
        @customers.each do |customer|
        filename=dt.strftime('%Y%m%d')+'請求書_'+customer.name+'様.xlsx'
          workbook = RubyXL::Parser.parse('app/assets/template.xlsx')  # app/assetsの下にtemplate.xlsxを配置した場合
          
          # エクセルの数式を動作されるための設定
          workbook.calc_pr.full_calc_on_load = true
          workbook.calc_pr.calc_completed = true
          workbook.calc_pr.calc_on_save = true
          workbook.calc_pr.force_full_calc = true
          # 一番目のワークシート読み込み
          worksheet = workbook[0]

          # データ書き込み
          worksheet.add_cell(8,2,customer.manager+' 様')

          cell = worksheet.add_cell(7,1,customer.name+' 御中')

          cell.change_border(:bottom, "medium")
          worksheet.add_cell(7,4,@user.company)
          worksheet.add_cell(8,5,@user.email)
          worksheet.add_cell(9,5,@user.username)

          worksheet.add_cell(4,5,dt.strftime("%Y/%m/%d")).change_horizontal_alignment("right")
          worksheet.add_cell(5,5, customer.code+'-'+dt.strftime("%Y%m%d")).change_horizontal_alignment("right")


          @user.account.each_line.with_index  do |str,index|
            worksheet.add_cell(44+index,1,str.chomp).change_border(:left,'medium')
          end

          num = 17
          customer.deals.each{|deal|
            cell = worksheet.add_cell(num,2,deal.title)
            [:bottom, :left].each do |e|
              cell.change_border(e, "thin")
            end
            
            cell=worksheet.add_cell(num,3,deal.amount)
            [:bottom, :left].each do |e|
              cell.change_border(e, "thin")
            end
            
            cell = worksheet.add_cell(num,4,deal.price)
            [:bottom, :left].each do |e|
              cell.change_border(e, "thin")
            end
            num += 1
          }            #上限への対応
          folder = "app/assets/books"
          workbook.write( File.join(folder, filename))
          @zipfile_name = "app/assets/books/invoice.zip"
          Zip::File.open(@zipfile_name, Zip::File::CREATE) do |zipfile|
              zipfile.add(filename, File.join(folder, filename))
          end
          FileUtils.rm(File.join(folder, filename))
        end

# 送信
        send_data(File.read(@zipfile_name), filename: dt.strftime('%Y%m%d')+"_請求書xlsx.zip")
        File.delete(@zipfile_name)
        #  send_data workbook.stream.read,
        #   filename: "請求書_"+customer.name+".xlsx".encode(Encoding::Windows_31J)
          # ensure
          #   workbook.stream.close  # streamを閉じる
      end
    end
  end

  def edit
    @customer = Customer.find(params[:id])
    if @customer.user.id != current_user.id
      redirect_to customers_path, alert: '不正なアクセスです' 
    end
  end

  def update
    @customer = Customer.find(params[:id])
    @customer.update(customer_params)
    redirect_to customer_path(@customer)
  end
  
  def destroy
    customer = Customer.find(params[:id])
    customer.destroy
    redirect_to customers_path
  end

  def create_invoice

  end


  private
  def customer_params
    params.require(:customer).permit(:name, :code, :manager)
  end

end
