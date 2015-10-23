package sfc.network.resp;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.util.logging.Level;
import sfc.network.Resp;

/**
 * 开启传输的结果
 * @author mcintype
 *
 */
public class StartTransResp implements Resp{
	public static final int ProtocolId = 0x2001;
	
	//返回码，0-成功 1-失败,文件已存在 2-其它失败，详情见errorMsg
	private int retCode;
	//提示信息
	private String errorMsg;
	
	//传输的id编号，成功时才有意义
	private int transId;

	@Override
	public byte[] toByteArray() {
		ByteArrayOutputStream bais = new ByteArrayOutputStream();
		DataOutputStream dis = new DataOutputStream(bais);
		
		try{
			if(errorMsg==null){
				errorMsg = "";
			}
			dis.writeInt(retCode);
			dis.writeUTF(errorMsg);
			dis.writeInt(transId);
			
			dis.flush();
			return bais.toByteArray();
		}catch(Exception e){
			e.printStackTrace();
			return null;
		}finally{
			try{
				dis.close();
				bais.close();
			}catch(Exception ex){
				ex.printStackTrace();
			}
		}
	}

	@Override
	public void fromDis(DataInputStream dis) {
		try{
			retCode = dis.readInt();
			errorMsg = dis.readUTF();
			transId = dis.readInt();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	
	public int getRetCode() {
		return retCode;
	}

	public void setRetCode(int retCode) {
		this.retCode = retCode;
	}

	public String getErrorMsg() {
		return errorMsg;
	}

	public void setErrorMsg(String errorMsg) {
		this.errorMsg = errorMsg;
	}

	public int getTransId() {
		return transId;
	}

	public void setTransId(int transId) {
		this.transId = transId;
	}
	
	@Override
	public int getProtocolId() {
		return ProtocolId;
	}

	@Override
	public String toString() {
		return "StartTransResp [retCode=" + retCode + ", errorMsg=" + errorMsg
				+ ", transId=" + transId + "]";
	}
	
}
