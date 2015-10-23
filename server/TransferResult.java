package sfc.network.resp;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.util.logging.Level;

import sfc.network.Resp;

/**
 * 正常完成，以及服务主动中断。都通过这个Result给
 * 
 * @author mcintype
 *
 */
public class TransferResult implements Resp{
	public static final int ProtocolId = 0x2003;
	

	// 返回码，0:成功 1:失败
	private int retCode;
	// 出错信息
	private String errorMsg;
	// 传输的id编号，成功时才有意义
	private int transId;

	// 服务端侧名称，不带后缀
	private String serverFileName;

	// 服务端侧后缀，不带点号
	private String serverFileType;

	// 访问的Url
	private String accessUrl;

	@Override
	public byte[] toByteArray() {
		ByteArrayOutputStream bais = new ByteArrayOutputStream();
		DataOutputStream dis = new DataOutputStream(bais);
		
		try{
			if(errorMsg==null){
				errorMsg = "";
			}
			
			if(serverFileName==null){
				serverFileName = "";
			}
			
			if(serverFileType==null){
				serverFileType = "";
			}
			
			if(accessUrl==null){
				accessUrl = "";
			}
			
			dis.writeInt(retCode);
			dis.writeUTF(errorMsg);
			dis.writeInt(transId);
			dis.writeUTF(serverFileName);
			dis.writeUTF(serverFileType);
			dis.writeUTF(accessUrl);
			
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
			serverFileName = dis.readUTF();
			serverFileType = dis.readUTF();
			accessUrl = dis.readUTF();
		}catch(Exception e){
			e.printStackTrace();
		}
		
	}
	
	public int getTransId() {
		return transId;
	}

	public void setTransId(int transId) {
		this.transId = transId;
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

	public String getServerFileName() {
		return serverFileName;
	}

	public void setServerFileName(String serverFileName) {
		this.serverFileName = serverFileName;
	}

	public String getServerFileType() {
		return serverFileType;
	}

	public void setServerFileType(String serverFileType) {
		this.serverFileType = serverFileType;
	}

	public String getAccessUrl() {
		return accessUrl;
	}

	public void setAccessUrl(String accessUrl) {
		this.accessUrl = accessUrl;
	}
	
	@Override
	public int getProtocolId() {
		return ProtocolId;
	}

	@Override
	public String toString() {
		return "TransferResult [retCode=" + retCode + ", errorMsg=" + errorMsg
				+ ", transId=" + transId + ", serverFileName=" + serverFileName
				+ ", serverFileType=" + serverFileType + ", accessUrl="
				+ accessUrl + "]";
	}
	
}
