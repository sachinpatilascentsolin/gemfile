require 'zlib'
require 'savon'

class Tpslutil
  def initialize
    puts "in ->Tpslutil"
  end
  #*** method for open property file
  # and get data - Biller id, response url, CRN, checksumkey
  def getPropdata(param)
    begin
      file=File.open(param)
      file_lines=file.read.split("\n")
      prop_hash=Hash.new
      for i in 0..file_lines.length-1
        str=String.new(file_lines[i])
        kval=str.split("=")
        prop_hash.store(kval[0],kval[1])
      end
    rescue
      return ''
    end
    return prop_hash
  end
  #*** calling web services using savon gem passing two parameters s and s1
  # s- string without checksum
  # s1- checksum key from property file
  def getCheckSum(s,s1)
    # ------ calling web service for checksum -------------------------------
    puts "calling webservice..."
    client = Savon.client(wsdl: "https://www.tekprocess.co.in/ChecksumWebService/services/CheckSumCalculator?wsdl")
    response = client.call(:calculate_check_sum, message: { s: s, s1: s1 })
    strxml =String.new("#{response.body}")
    arrxml= strxml.split("=>")
    strxml1=String.new(arrxml[2]).split("\"")
    strxml2= strxml1[1]
    puts strxml2
    s= strxml2
    return s
  end
  def self.transactionRequestMessage(paramObject)

    # object used for calling private method
    tpslobj=Tpslutil.new

    str1 =paramObject.getStrMerchantTranId()
    str2 = paramObject.getStrMarketCode();
    str3 = paramObject.getStrAccountNo();
    str4 = paramObject.getStrAmt();
    str5 = paramObject.getStrBankCode();
    paramObject = paramObject.getStrPropertyPath();
    if ((str1.nil?) || (str2.nil?) || (str3.nil?)|| (str4.nil?) || (str5.nil?) || (paramObject.nil?))
      str1 = '';
    else
      begin

        localObject=tpslobj.instance_eval{getPropdata(paramObject)}

        if localObject.size>=3
          str6="#{localObject['BillerId']}"
          str7="#{localObject['ResponseUrl']}"
          ckechsumkey="#{localObject['CheckSumKey']}"
          localObject="#{localObject['CRN']}"
          str1=str6 + '|' + str1 + '|NA|NA|' + str4 + '|' + str5 + '|NA|NA|' + localObject + '|NA|NA|NA|NA|NA|NA|NA|' + str2 + '|' + str3 + '|NA|NA|NA|NA|NA|' + str7
          #*** web service calling start ***
          begin
            checksumstring="#{str1}"
            puts "string & ch_key\n #{checksumstring}\n#{ckechsumkey}"
            puts "---- web service ----"
            str1=checksumstring+"|"+ tpslobj.instance_eval{getCheckSum(checksumstring, ckechsumkey)}
          rescue Exception=>e
            puts "Error: Checksum not created successfully..."+e.message
            abort "Error: Checksum not created successfully..."+e.message
          end
        else
          puts 'Property file not found!!!'
          abort 'Error:Property file not found!!!'
          str1=''
        end
      rescue  Exception => e
        str1=''
        abort 'Error:Request not processed...\n'+ e.message
      end
    end
    return str1
  end
  def self.transactionResponseMessage(paramObject)
    tpslobj=Tpslutil.new
    begin
      str1 =paramObject. getStrMSG();
      str2 = paramObject.getStrPropertyPath();
      str1=str1.split("|")
      checksum2=str1[25]
      puts "checksum2=#{checksum2}"
      if(checksum2.nil?)
        return 'Transaction Fails, Invalid Response!'
      end
      str=''
      for i in 0..24
        str=str+str1[i]+(i==24?"":"|")
      end
      puts "str=#{str}"
      localObject=tpslobj.instance_eval{getPropdata(str2)}
      str2= "#{localObject['CheckSumKey']}"
      puts "chesumkey=#{str2}"
      checksum3=tpslobj.instance_eval{getCheckSum(str,str2)}
      puts "checksum3=#{checksum3}"
      str= ((checksum2.eql?checksum3)?"success":"fail")
    rescue Exception =>e
      puts 'Error: checksum is not generated from response message...'+e.message
      str=''
      abort 'Error: checksum is not generated from response message...'+e.message
    end
    return str
  end
  private :getPropdata, :getCheckSum
end

######### Request Bean ########
class Tpslutil::CheckSumRequestBean
  @a = ''
  @b = ''
  @c = ''
  @d = ''
  @e = ''
  @f = ''

  def initialize
    puts "In-->CheckSumRequestBean..."
  end
  def   getStrMerchantTranId()
    return @a;
  end

  def  setStrMerchantTranId( param)
    @a = param;
  end

  def   getStrMarketCode()
    return @b;
  end

  def  setStrMarketCode( param)
    @b = param;
  end

  def   getStrAccountNo()
    return @c;
  end

  def  setStrAccountNo( param)
    @c = param;
  end

  def   getStrAmt()
    return @d;
  end

  def  setStrAmt( param)
    @d = param;
  end

  def   getStrBankCode()
    return @e;
  end

  def  setStrBankCode( param)
    @e = param;
  end

  def   getStrPropertyPath()
    return @f;
  end

  def  setStrPropertyPath( param)
    @f = param;
  end

  def  setStrResponseMsg( param)
  end
end

###### Responsebean #######
class Tpslutil::CheckSumResponseBean
  @a = ''
  @b = ''
  def initialize
    puts "in ->CheckSumResponseBean..."
  end
  def   getStrMSG()
    return @a;
  end

  def  setStrMSG( param)
    @a = param;
  end

  def   getStrPropertyPath()
    return @b;
  end

  def  setStrPropertyPath( param)
    @b = param;
  end
end
