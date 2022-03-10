


//I2S Receiver

module I2S_receiver 
  #(parameter AudioWidth		= 8,  // Bits per audio channel
parameter BitCounterWidth	= $clog2(AudioWidth)	
)
  (	input 			LRCLK,  //Left or Right Channel clock (AKA WS)
	input 			SCLK,	//Serial clock
	input 			SD,		//Serial Data: Digital Audio In
	input 			RESET,
  output reg [AudioWidth-1:0] 	LeftChAudio,  // Left channel audio output data
  output reg [AudioWidth-1:0] 	RightChAudio  // Right channel audio output data
  );
reg							current_ch;		// current channel, last LRCLK read
reg [BitCounterWidth-1:0]	bitIndex;
reg [AudioWidth-1:0] 		shiftSIPO;		// Shift reg Serial In Parallel Out

//on Bit-Clock rise edge	
	always @(posedge SCLK) begin
		if (RESET) begin			//Reset
			LeftChAudio <= 0;
			RightChAudio <= 0;
			shiftSIPO <= 0;
			current_ch <= 0;
			
			bitIndex <= AudioWidth;
		end
		else begin
		if (LRCLK != current_ch) begin   //On channel change
				current_ch <= LRCLK;
				bitIndex <= AudioWidth;
				shiftSIPO <= 0;
				
		end
		else if (bitIndex > 0) begin				//SIPO loop
				shiftSIPO <= {shiftSIPO[AudioWidth-2:0], SD};
				bitIndex <= bitIndex-1;
		end
		else if (bitIndex == 0) begin			//write finished sample
					if (current_ch) begin
						RightChAudio <= shiftSIPO;
					end
					else begin  
						LeftChAudio <= shiftSIPO;
					end
		end
		end
	end


	function integer clog2;
		input integer value;
		begin
		value = value-1;
		for (clog2=0; value>0; clog2=clog2+1)
		value = value>>1;
		end
	endfunction

endmodule
