using System; 
using System.Data; 
using System.Data.SqlClient; 
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

namespace Aggregate;

[Serializable]
[SqlUserDefinedAggregate(
   Format.Native,
   IsInvariantToDuplicates = false,
   IsInvariantToNulls = true,
   IsInvariantToOrder = true,
   IsNullIfEmpty = false)]
public struct Skew
{
   private double rx;
   private double rx2;
   private double r2x;
   private double rx3;
   private double r3x2;
   private double r3x;
   private Int64 rn;

   public void Init()
   {
      rx = 0;
      rx2 = 0;
      r2x = 0;
      rx3 = 0;
      r3x2 = 0;
      r3x = 0;
      rn = 0;
   }

   public void Accumulate(SqlDouble inpVal)
   {
      if (inpVal.IsNull)
      {
         return;
      }

      rx += inpVal.Value;
      rx2 += Math.Pow(inpVal.Value, 2);
      r2x += 2 * inpVal.Value;
      rx3 += Math.Pow(inpVal.Value, 3);
      r3x2 += 3 * Math.Pow(inpVal.Value, 2);
      r3x += 3 * inpVal.Value;
      rn += 1;
   }

   public void Merge(Skew Group)
   {
      this.rx += Group.rx;
      this.rx2 += Group.rx2;
      this.r2x += Group.r2x;
      this.rx3 += Group.rx3;
      this.r3x2 += Group.r3x2;
      this.r3x += Group.r3x;
      this.rn += Group.rn;
   }
   
   public SqlDouble Terminate() 
   { 
      double myAvg = (rx / rn); 
      double myStDev = Math.Pow((rx2 - r2x * myAvg + rn * Math.Pow(myAvg, 2)) 
                     / (rn - 1), 1d / 2d); 
      double mySkew = (rx3 - r3x2 * myAvg + r3x * Math.Pow(myAvg, 2) 
                     - rn * Math.Pow(myAvg, 3)) / 
                     Math.Pow(myStDev,3) * rn / (rn - 1) / (rn - 2); 
      return (SqlDouble)mySkew; 
   } 
}
