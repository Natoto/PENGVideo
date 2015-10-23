package sfc.network.req;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.util.logging.Level;

import sfc.network.Req;

public class AuthReq implements Req {
	public static final int ProtocolId = 0x1002;
	
	//用户Key
	private String uKey;
	//用户密钥
	private String uSecret;
		
	@Override
	public int getProtocolId() {
		return ProtocolId;
	}

	@Override
	public void fromDis(DataInputStream dis) {
		try{
			uKey = dis.readUTF();
			uSecret = dis.readUTF();
		}catch(Exception e){
			e.printStackTrace();
		}
	}

	@Override
	public byte[] toByteArray() {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(baos);
		
		try{
			if(uKey==null){
				uKey = "";
			}
			dos.writeUTF(uKey);
			
			if(uSecret==null){
				uSecret = "";
			}
			dos.writeUTF(uSecret);
			
			dos.flush();
			return baos.toByteArray();
		}catch(Exception e){
			e.printStackTrace();
			return null;
		}finally{
			try{
				dos.close();
				baos.close();
			}catch(Exception ex){
				ex.printStackTrace();
			}
		}
		
		
	}
	
	public String getuKey() {
		return uKey;
	}

	public void setuKey(String uKey) {
		this.uKey = uKey;
	}

	public String getuSecret() {
		return uSecret;
	}

	public void setuSecret(String uSecret) {
		this.uSecret = uSecret;
	}

	@Override
	public String toString() {
		return "AuthReq [uKey=" + uKey + ", uSecret=" + uSecret + "]";
	}

}
