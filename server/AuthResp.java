package sfc.network.resp;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.util.logging.Level;

import sfc.network.Resp;

public class AuthResp implements Resp {
	public static final int ProtocolId = 0x2002;

	// 返回码，0-成功 1-失败
	private int retCode;
	// 提示信息
	private String errorMsg;

	@Override
	public int getProtocolId() {
		return ProtocolId;
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
		}catch(Exception e){
			e.printStackTrace();
		}
	}

	@Override
	public String toString() {
		return "AuthResp [retCode=" + retCode + ", errorMsg=" + errorMsg + "]";
	}

}
