#ifndef CLK_WIZ_HPP
#define CLK_WIZ_HPP

#include "api/kernel.hpp"
#include <unistd.h>

#include <iostream>
#include <iomanip>


namespace vrt {
    #define XCLK_WIZ_HANDLER_CLK_OUTOF_RANGE	1
    #define XCLK_WIZ_HANDLER_CLK_GLITCH		2
    #define XCLK_WIZ_HANDLER_CLK_STOP		3
    #define XCLK_WIZ_HANDLER_CLK_OTHER_ERROR	4

    #define XCLK_M_MIN 4
    #define XCLK_M_MAX 432
    #define XCLK_D_MIN 1
    #define XCLK_D_MAX 123
    #define XCLK_VCO_MIN  2160
    #define XCLK_VCO_MAX  4320
    #define XCLK_O_MIN 2
    #define XCLK_O_MAX 511

    #define XCLK_US_VCO_MAX 1600
    #define XCLK_US_VCO_MIN 800
    #define XCLK_US_M_MIN 2
    #define XCLK_US_M_MAX 128
    #define XCLK_US_D_MAX 106
    #define XCLK_US_D_MIN 1
    #define XCLK_US_O_MAX 128
    #define XCLK_US_O_MIN 1

    #define XCLK_MHZ 1000000
        typedef struct {
    #ifndef SDT
        uint32_t DeviceId;	         /**< Device Id */
    #else
        char *Name;
    #endif
        uint64_t BaseAddr;        /**< Base address of CLK_WIZ Controller */
        uint32_t EnableClkMon;        /**< It enables the Clock Monitor*/
        uint32_t EnableUserClkWiz0;   /**< Enable user clk 0 */
        uint32_t EnableUserClkWiz1;   /**< Enable user clk 1 */
        uint32_t EnableUserClkWiz2;   /**< Enable user clk 2 */
        uint32_t EnableUserClkWiz3;   /**< Enable user clk 3 */
        double RefClkFreq;       /**< Frequency of Reference Clock */
        double UserClkFreq0;   /**< Hold the  user clock frequency0 */
        double UserClkFreq1;   /**< Hold the  user clock frequency1 */
        double UserClkFreq2;   /**< Hold the  user clock frequency2 */
        double UserClkFreq3;   /**< Hold the  user clock frequency3 */
        double Precision;      /**< Holds the value of precision */
        uint8_t  EnablePll0;        /**< specify if this user clock is
                    going as input to the PLL/MMCM */
        uint8_t  EnablePll1;        /**< specify if this user clock is
                    going as input to the PLL/MMCM */

        uint64_t PrimInClkFreq;       /**< Input Clock */
        uint32_t NumClocks;		/**< Number of clocks */
    #ifdef SDT
        u32 IntId;		/**< Interrupt ID on GIC **/
        UINTPTR IntrParent; 	/** Bit[0] Interrupt parent type Bit[64/32:1]
                    * Parent base address */
    #endif
    } XClk_Wiz_Config;

    typedef void (*XClk_Wiz_CallBack) (void *CallBackRef, uint32_t Mask);
    
    typedef struct {

        XClk_Wiz_Config Config;		/**< GUI Configuration */
        uint32_t  ClkWizIntrStatus;	/**< Clock Stop, Clock Overrun,
                    *  Clock Underrun, Clock Glitch
                    * Interrupt Status */
        uint32_t  ClkIntrEnable;	/**< Interrupt enable for
                    *  Clock Stop, Clock Overrun,
                    *  Clock Underrun, Clock Glitch */
        XClk_Wiz_CallBack ClkOutOfRangeCallBack;/**< Callback for Clock out
                            *  of range Under flow
                            * .or over flow */
        void *ClkOutOfRangeRef;	 /**< To be passed to the clock
                    *  out of range call back */
        XClk_Wiz_CallBack ClkGlitchCallBack; /**< Callback for
                            *  Clock Glitch */
        void *ClkGlitchRef;		/**< To be passed to the
                        *  clock glitch call back */
        XClk_Wiz_CallBack ClkStopCallBack;	/**< Callback for Clock stop */
        void *ClkStopRef;			/**< To be passed to the clock
                            *  stop call back */
        XClk_Wiz_CallBack ErrorCallBack; /**< Call back function
                        *  for rest all errors */
        void *ErrRef; /**< To be passed to the Error Call back */
        uint32_t IsReady; /**< Driver is ready */
        uint32_t MVal;	/* Multiplier valuer */
        uint32_t DVal;	/* Divisor value */
        uint32_t  OVal;	/* Output Value */
        uint64_t MinErr;	/* Min Error that is acceptable */
    } XClk_Wiz;

    #define XCLK_WIZ_STATUS_OFFSET	0x00000004  /**< Status Register */
    #define XCLK_WIZ_ISR_OFFSET	0x0000000C  /**< Interrupt Status Register */
    #define XCLK_WIZ_IER_OFFSET	0x00000010  /**< Interrupt Enable Register */
    #define XCLK_WIZ_RECONFIG_OFFSET	0x00000014  /**< Reconfig Register */
    #define XCLK_WIZ_REG1_OFFSET	0x00000330
    #define XCLK_WIZ_REG2_OFFSET	0x00000334
    #define XCLK_WIZ_REG3_OFFSET	0x00000338
    #define XCLK_WIZ_REG4_OFFSET	0x0000033C
    #define XCLK_WIZ_REG12_OFFSET	0x00000380
    #define XCLK_WIZ_REG13_OFFSET	0x00000384
    #define XCLK_WIZ_REG11_OFFSET	0x00000378
    #define XCLK_WIZ_REG14_OFFSET	0x00000398
    #define XCLK_WIZ_REG15_OFFSET	0x0000039C
    #define XCLK_WIZ_REG16_OFFSET	0x000003A0
    #define XCLK_WIZ_REG17_OFFSET	0x000003A8
    #define XCLK_WIZ_REG19_OFFSET	0x000003CC
    #define XCLK_WIZ_REG25_OFFSET	0x000003F0
    #define XCLK_WIZ_REG26_OFFSET	0x000003FC

    #define XCLK_WIZ_ZYNQMP_REG0_OFFSET	0x00000200
    #define XCLK_WIZ_ZYNQMP_REG2_OFFSET	0x00000208

    #define XCLK_WIZ_REG0_FBMULT_SHIFT	8
    #define XCLK_WIZ_REG0_FBMULT_WIDTH	8
    #define XCLK_WIZ_REG0_FBMULT_MASK	0xFF00
    #define XCLK_WIZ_REG0_DIV_MASK		0xFF
    #define XCLK_WIZ_REG0_DIV_WIDTH		8
    #define XCLK_WIZ_REG2_DIV_MASK		0xFF

    #define XCLK_WIZ_REG1_EDGE_SHIFT	8
    #define XCLK_WIZ_REG1_EDGE_MASK		0x100
    #define XCLK_WIZ_CLKFBOUT_L_MASK	0xFF
    #define XCLK_WIZ_CLKFBOUT_H_MASK	0xFF00
    #define XCLK_WIZ_CLKFBOUT_H_SHIFT	8

    #define XCLK_WIZ_EDGE_MASK			(1 << 10) /** Edge */
    #define XCLK_WIZ_P5EN_MASK			(1 << 8)  /** p5en */
    #define XCLK_WIZ_LOCK				1    /** Lock */
    #define XCLK_WIZ_REG3_PREDIV2			(1 << 11)    /**< Prediv2  3*/
    #define XCLK_WIZ_REG3_USED			(1 << 12)    /**< Prediv2  3*/
    #define XCLK_WIZ_REG3_MX			(1 << 9)    /**< MX*/
    #define XCLK_WIZ_REG1_PREDIV2			(1 << 12)    /**< Prediv2  3*/
    #define XCLK_WIZ_REG1_EN			(1 << 9)    /**< FBout enable*/
    #define XCLK_WIZ_REG1_MX			(1 << 10)    /**< MX  3*/
    #define XCLK_WIZ_RECONFIG_LOAD			1
    #define XCLK_WIZ_RECONFIG_SADDR			2

    #define XCLK_WIZ_CLKOUT0_PREDIV2_SHIFT		11   /**< Shift bits for Prediv2 */
    #define XCLK_WIZ_CLKOUT0_MX_SHIFT		9   /**< Shift bits for MUX */
    #define XCLK_WIZ_CLKOUT0_P5EN_SHIFT		13   /**< Shift bits for P5EN */
    #define XCLK_WIZ_CLKOUT0_P5FEDGE_SHIFT		15  /**< Shift bits for P5EDGE */
    #define XCLK_WIZ_CLKOUT0_P5FEDGE_MASK		(1 << 15)  /**< Mask for P5EDGE */
    #define XCLK_WIZ_REG12_EDGE_SHIFT		10  /**< Shift bits for Edge */
    #define XCLK_WIZ_REG1_EDGE_SHIFT		8  /**< Shift bits for Edge */
/*@}*/
    /*@}*/

    /** @name Bitmasks and offsets of XCLK_WIZ_ISR_OFFSET register
     * This register is used to display interrupt status register
     * @{
     */

    #define XCLK_WIZ_ISR_CLK3_STOP_MASK	0x00008000    /**< User clock 3 stopped */
    #define XCLK_WIZ_ISR_CLK2_STOP_MASK	0x00004000    /**< User clock 2 stopped */
    #define XCLK_WIZ_ISR_CLK1_STOP_MASK	0x00002000    /**< User clock 1 stopped */
    #define XCLK_WIZ_ISR_CLK0_STOP_MASK	0x00001000    /**< User clock 0 stopped */
    #define XCLK_WIZ_ISR_CLK3_GLITCH_MASK	0x00000800    /**< User clock 3 has glitch */
    #define XCLK_WIZ_ISR_CLK2_GLITCH_MASK	0x00000400    /**< User clock 2 has glitch */
    #define XCLK_WIZ_ISR_CLK1_GLITCH_MASK	0x00000200    /**< User clock 1 has glitch */
    #define XCLK_WIZ_ISR_CLK0_GLITCH_MASK	0x00000100    /**< User clock 0 has glitch */
    #define XCLK_WIZ_ISR_CLK3_MINFREQ_MASK	0x00000080    /**< User clock 3 is less than specification */
    #define XCLK_WIZ_ISR_CLK2_MINFREQ_MASK	0x00000040    /**< User clock 2 is less than specification */
    #define XCLK_WIZ_ISR_CLK1_MINFREQ_MASK	0x00000020    /**< User clock 1 is less than specification */
    #define XCLK_WIZ_ISR_CLK0_MINFREQ_MASK	0x00000010    /**< User clock 0 is less than specification */
    #define XCLK_WIZ_ISR_CLK3_MAXFREQ_MASK	0x00000008    /**< User clock 3 is max than specification */
    #define XCLK_WIZ_ISR_CLK2_MAXFREQ_MASK	0x00000004    /**< User clock 2 is max than specification */
    #define XCLK_WIZ_ISR_CLK1_MAXFREQ_MASK	0x00000002    /**< User clock 1 is max than specification */
    #define XCLK_WIZ_ISR_CLK0_MAXFREQ_MASK	0x00000001    /**< User clock 0 is max than specification */

    #define XCLK_WIZ_ISR_CLKALL_STOP_MASK	0x0000F000    /**< User clock[0-3] has stopped*/
    #define XCLK_WIZ_ISR_CLKALL_GLITCH_MASK	0x00000F00    /**< User clock[0-3] has glitch */
    #define XCLK_WIZ_ISR_CLKALL_MINFREQ_MASK 0x000000F0    /**< User clock[0-3] is min than specification */
    #define XCLK_WIZ_ISR_CLKALL_MAXFREQ_MASK 0x0000000F    /**< User clock[0-3] is max than specification */

    #define XCLK_WIZ_ISR_CLK3_STOP_SHIFT              15   /**< Shift bits for User clock 3 stop*/
    #define XCLK_WIZ_ISR_CLK2_STOP_SHIFT              14   /**< Shift bits for User clock 2 stop*/
    #define XCLK_WIZ_ISR_CLK1_STOP_SHIFT              13   /**< Shift bits for User clock 1 stop*/
    #define XCLK_WIZ_ISR_CLK0_STOP_SHIFT              12   /**< Shift bits for User clock 0 stop*/
    #define XCLK_WIZ_ISR_CLK3_GLITCH_SHIFT            11   /**< Shift bits for User clock 3 glitch */
    #define XCLK_WIZ_ISR_CLK2_GLITCH_SHIFT            10   /**< Shift bits for User clock 2 glitch */
    #define XCLK_WIZ_ISR_CLK1_GLITCH_SHIFT             9   /**< Shift bits for User clock 1 glitch */
    #define XCLK_WIZ_ISR_CLK0_GLITCH_SHIFT             8   /**< Shift bits for User clock 0 glitch */
    #define XCLK_WIZ_ISR_CLK3_MINFREQ_SHIFT            7   /**< Shift bits for User clock 3 less */
    #define XCLK_WIZ_ISR_CLK2_MINFREQ_SHIFT            6   /**< Shift bits for User clock 2 less */
    #define XCLK_WIZ_ISR_CLK1_MINFREQ_SHIFT            5   /**< Shift bits for User clock 1 less */
    #define XCLK_WIZ_ISR_CLK0_MINFREQ_SHIFT            4   /**< Shift bits for User clock 0 less */
    #define XCLK_WIZ_ISR_CLK3_MAXFREQ_SHIFT            3   /**< Shift bits for User clock 3 max */
    #define XCLK_WIZ_ISR_CLK2_MAXFREQ_SHIFT            2   /**< Shift bits for User clock 2 max */
    #define XCLK_WIZ_ISR_CLK1_MAXFREQ_SHIFT            1   /**< Shift bits for User clock 1 max */
    #define XCLK_WIZ_ISR_CLK0_MAXFREQ_SHIFT            0   /**< Shift bits for User clock 0 max */
    /*@}*/

    /** @name Bitmasks and offsets of XCLK_WIZ_IER_OFFSET register
     * This register is used to display interrupt status register
     * @{
     */

    #define XCLK_WIZ_IER_CLK3_STOP_MASK	0x00008000    /**< User clock 3 stopped */
    #define XCLK_WIZ_IER_CLK2_STOP_MASK	0x00004000    /**< User clock 2 stopped */
    #define XCLK_WIZ_IER_CLK1_STOP_MASK	0x00002000    /**< User clock 1 stopped */
    #define XCLK_WIZ_IER_CLK0_STOP_MASK	0x00001000    /**< User clock 0 stopped */
    #define XCLK_WIZ_IER_CLK3_GLITCH_MASK	0x00000800    /**< User clock 3 has glitch */
    #define XCLK_WIZ_IER_CLK2_GLITCH_MASK	0x00000400    /**< User clock 2 has glitch */
    #define XCLK_WIZ_IER_CLK1_GLITCH_MASK	0x00000200    /**< User clock 1 has glitch */
    #define XCLK_WIZ_IER_CLK0_GLITCH_MASK	0x00000100    /**< User clock 0 has glitch */
    #define XCLK_WIZ_IER_CLK3_MINFREQ_MASK	0x00000080    /**< User clock 3 is less than specification */
    #define XCLK_WIZ_IER_CLK2_MINFREQ_MASK	0x00000040    /**< User clock 2 is less than specification */
    #define XCLK_WIZ_IER_CLK1_MINFREQ_MASK	0x00000020    /**< User clock 1 is less than specification */
    #define XCLK_WIZ_IER_CLK0_MINFREQ_MASK	0x00000010    /**< User clock 0 is less than specification */
    #define XCLK_WIZ_IER_CLK3_MAXFREQ_MASK	0x00000008    /**< User clock 3 is max than specification */
    #define XCLK_WIZ_IER_CLK2_MAXFREQ_MASK	0x00000004    /**< User clock 2 is max than specification */
    #define XCLK_WIZ_IER_CLK1_MAXFREQ_MASK	0x00000002    /**< User clock 1 is max than specification */
    #define XCLK_WIZ_IER_CLK0_MAXFREQ_MASK	0x00000001    /**< User clock 0 is max than specification */

    #define XCLK_WIZ_IER_CLK3_STOP_SHIFT              15   /**< Shift bits for User clock 3 stop*/
    #define XCLK_WIZ_IER_CLK2_STOP_SHIFT              14   /**< Shift bits for User clock 2 stop*/
    #define XCLK_WIZ_IER_CLK1_STOP_SHIFT              13   /**< Shift bits for User clock 1 stop*/
    #define XCLK_WIZ_IER_CLK0_STOP_SHIFT              12   /**< Shift bits for User clock 0 stop*/
    #define XCLK_WIZ_IER_CLK3_GLITCH_SHIFT            11   /**< Shift bits for User clock 3 glitch */
    #define XCLK_WIZ_IER_CLK2_GLITCH_SHIFT            10   /**< Shift bits for User clock 2 glitch */
    #define XCLK_WIZ_IER_CLK1_GLITCH_SHIFT             9   /**< Shift bits for User clock 1 glitch */
    #define XCLK_WIZ_IER_CLK0_GLITCH_SHIFT             8   /**< Shift bits for User clock 0 glitch */
    #define XCLK_WIZ_IER_CLK3_MINFREQ_SHIFT            7   /**< Shift bits for User clock 3 less */
    #define XCLK_WIZ_IER_CLK2_MINFREQ_SHIFT            6   /**< Shift bits for User clock 2 less */
    #define XCLK_WIZ_IER_CLK1_MINFREQ_SHIFT            5   /**< Shift bits for User clock 1 less */
    #define XCLK_WIZ_IER_CLK0_MINFREQ_SHIFT            4   /**< Shift bits for User clock 0 less */
    #define XCLK_WIZ_IER_CLK3_MAXFREQ_SHIFT            3   /**< Shift bits for User clock 3 max */
    #define XCLK_WIZ_IER_CLK2_MAXFREQ_SHIFT            2   /**< Shift bits for User clock 2 max */
    #define XCLK_WIZ_IER_CLK1_MAXFREQ_SHIFT            1   /**< Shift bits for User clock 1 max */
    #define XCLK_WIZ_IER_CLK0_MAXFREQ_SHIFT            0   /**< Shift bits for User clock 0 max */
    /*@}*/

    #define XCLK_WIZ_IER_ALLINTR_MASK	0x0000FFFF /**< All interrupts enable mask */
    #define XCLK_WIZ_IER_ALLINTR_SHIFT	         0 /**< All interrupts enable shift bits */

    #define XCLK_WIZ_ISR_ALLINTR_MASK	0x0000FFFF /**< All interrupt status register mask */
    #define XCLK_WIZ_ISR_ALLINTR_SHIFT	         0 /**< All interrupts status register shift */
    #define XCLK_WIZ_MAX_OUTPUT			7
    
/**
 * @class ClkWiz
 * @brief A class to manage and configure the clock wizard.
 * 
 * The ClkWiz class provides methods to configure and manage the clock settings
 * for a given device. It inherits from the Kernel class and provides additional
 * functionality specific to clock management.
 */
class ClkWiz : public Kernel {
    private:
        XClk_Wiz* instancePtr; /**< Pointer to the clock wizard instance. */
        uint64_t clockFrequency; /**< The current clock frequency. */

        /**
         * @brief Get the current clock rate.
         * 
         * @return The current clock rate in Hz.
         */
        uint64_t getClockRate();

        /**
         * @brief Get the VCO (Voltage-Controlled Oscillator) frequency.
         * 
         * @return The VCO frequency in Hz.
         */
        uint64_t getVco();

        /**
         * @brief Set the clock rate internally.
         * 
         * @param rate The desired clock rate in Hz.
         */
        void setRateHzInternal(uint64_t rate);

        /**
         * @brief Calculate the divisors for the given clock rate.
         * 
         * @param SetRate The desired clock rate in Hz.
         */
        void calculateDivisorsHz(uint64_t SetRate);

        /**
         * @brief Update the O (Output) divisor.
         */
        void updateO();

        /**
         * @brief Update the D (Divider) divisor.
         */
        void updateD();

        /**
         * @brief Update the M (Multiplier) divisor.
         */
        void updateM();

        /**
         * @brief Wait for the clock to lock.
         * 
         * @return The status of the lock operation.
         */
        uint32_t waitForLock();

    public:
        /**
         * @brief Constructor for the ClkWiz class.
         * 
         * @param device Pointer to the ami_device.
         * @param name The name of the clock wizard instance.
         * @param baseAddr The base address of the clock wizard.
         * @param range The address range of the clock wizard.
         * @param clockFreq The initial clock frequency in Hz.
         */
        ClkWiz(ami_device* device, const std::string& name, uint64_t baseAddr, uint64_t range, uint64_t clockFreq);

        /**
         * @brief Set the clock rate.
         * 
         * @param rate The desired clock rate in Hz.
         * @param verbose If true, print verbose output.
         */
        void setRateHz(uint64_t rate, bool verbose = true);
};

} // namespace vrt
#endif // CLK_WIZ_HPP