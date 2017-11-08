
import UIKit


public extension UIImage
{
    func scaledToSize(_ size: CGSize) -> UIImage
    {
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func colorArt(_ scale: CGSize = CGSize(width: 512, height: 512)) -> ColorArt
    {
        return ColorArt(image: self.scaledToSize(scale))
    }
    
}

public class ColorArt: NSObject
{
    var randomColorThreshold: Int
    var image: UIImage
    public var backgroundColor: UIColor!
    public var primaryColor: UIColor!
    public var secondaryColor: UIColor!
    public var detailColor: UIColor!
    
    var bestColor: UIColor {
        let bestColor = [detailColor, primaryColor, backgroundColor, secondaryColor].first(where: { $0 != UIColor.black && $0 != UIColor.white })
        return (bestColor ?? detailColor)!
    }
    
    init(image: UIImage, threshold: Int = 15)
    {
        self.randomColorThreshold = threshold
        self.image = image
        
        super.init()
        
        self.processImage()
    }
    
    class func processImage(_ image: UIImage, scaledToSize size: CGSize, withThreshold threshold: NSInteger, completion:@escaping (ColorArt)->())
    {
        DispatchQueue.global(qos: .default).async {
            let scaledImage = image.scaledToSize(size)
            let colorArt = ColorArt(image: scaledImage, threshold: threshold)
            DispatchQueue.main.async {
                completion(colorArt)
            }
        }
    }
    
    func scaleImage(_ image: UIImage, scaledSize: CGSize) -> UIImage
    {
        return image.scaledToSize(scaledSize)
    }
    
    func processImage()
    {
        let colors = self.analyzeImage(self.image)
        
        self.backgroundColor = colors.backgroundColor
        self.primaryColor    = colors.primaryColor
        self.secondaryColor  = colors.secondaryColor
        self.detailColor     = colors.detailColor
    }
    
    func analyzeImage(_ image: UIImage) -> (backgroundColor: UIColor, primaryColor: UIColor, secondaryColor: UIColor, detailColor: UIColor)
    {
        var imageColors = NSCountedSet()
        var backgroundColor: UIColor?
        (backgroundColor: backgroundColor, imageColors: imageColors) = self.findEdgeColor(image)
        var primaryColor: UIColor?
        var secondaryColor: UIColor?
        var detailColor: UIColor?
        
        backgroundColor = backgroundColor ?? UIColor.white
        
        let darkBackground = backgroundColor!.isDarkColor
        
        (primaryColor, secondaryColor, detailColor) = self.findTextColors(imageColors, primaryColor: primaryColor, secondaryColor: secondaryColor, detailColor: detailColor, backgroundColor: backgroundColor!)
        if primaryColor == nil
        {
            primaryColor = darkBackground ? UIColor.white : UIColor.black
        }
        
        if secondaryColor == nil
        {
            secondaryColor = darkBackground ? UIColor.white : UIColor.black
        }
        
        if detailColor == nil
        {
            detailColor = darkBackground ? UIColor.white : UIColor.black
        }
        
        return (backgroundColor: backgroundColor!, primaryColor: primaryColor!, secondaryColor: secondaryColor!, detailColor: detailColor!)
    }
    
    struct RGBAPixel
    {
        let red: UInt8
        let green: UInt8
        let blue: UInt8
        let alpha: UInt8
    }
    
    func findEdgeColor(_ image: UIImage) -> (backgroundColor: UIColor?, imageColors: NSCountedSet)
    {
        let imageref = image.cgImage
        let width = imageref?.width
        let height = imageref?.height
        
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = width! * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = Pixel.bitmapInfo
        let context = CGContext(data: nil, width: width!, height: height!, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        
        let rect = CGRect(x: 0, y: 0, width: CGFloat(width!), height: CGFloat(height!))
        context?.draw(imageref!, in: rect)
        
        let imageColors = NSCountedSet(capacity: width! * height!)
        let edgeColors = NSCountedSet(capacity: height!)
        
        let ptr = UnsafeMutableRawPointer(context!.data!)
        let pixels = ptr.assumingMemoryBound(to: Pixel.self)
        
        for row in 0 ..< height! {
            for col in 0 ..< width! {
                let offset = Int(row * width! + col)
                
                let red = CGFloat(pixels[offset].red)
                let green = CGFloat(pixels[offset].green)
                let blue = CGFloat(pixels[offset].blue)
                let alpha = CGFloat(pixels[offset].alpha)
                let color = UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha/255)
                
                if col == 0 { edgeColors.add(color) }
                imageColors.add(color)
            }
        }
        
        var sortedColors = [CountedColor]()
        let enumerator = edgeColors.objectEnumerator()
        
        while let curColor = enumerator.nextObject() as? UIColor
        {
            let colorCount = edgeColors.count(for: curColor)
            if colorCount <= self.randomColorThreshold { continue }
            let container = CountedColor(color: curColor, count: colorCount)
            sortedColors.append(container)
        }
        
        sortedColors.sort()
        
        var proposedEdgeColor: CountedColor?
        if sortedColors.count > 0
        {
            proposedEdgeColor = sortedColors.first!
            if proposedEdgeColor!.color.isBlackOrWhite
            {
                for i in 1 ..< sortedColors.count
                {
                    let nextProposedColor = sortedColors[i]
                    if Double(nextProposedColor.count) / Double(proposedEdgeColor!.count) > 0.4
                    {
                        if !nextProposedColor.color.isBlackOrWhite
                        {
                            proposedEdgeColor = nextProposedColor
                            break
                        }
                    }
                    else
                    {
                        break
                    }
                }
            }
        }
        return (backgroundColor:  proposedEdgeColor?.color, imageColors: imageColors)
    }
    
    func findTextColors(_ colors: NSCountedSet, primaryColor: UIColor?, secondaryColor: UIColor?, detailColor: UIColor?, backgroundColor: UIColor) -> (primaryColor: UIColor?, secondaryColor: UIColor?, detailColor: UIColor?)
    {
        var tempPC = primaryColor
        var tempSC = secondaryColor
        var tempDC = detailColor
        let enumerator = colors.objectEnumerator()
        var sortedColors = [CountedColor]()
        let findDarkTextColor = !backgroundColor.isDarkColor
        while var curColor = enumerator.nextObject() as? UIColor
        {
            curColor = curColor.colorWithMinimumSaturation(0.15)
            
            if curColor.isDarkColor == findDarkTextColor
            {
                let colorCount = colors.count(for: curColor)
                
                let container = CountedColor(color: curColor, count: colorCount)
                sortedColors.append(container)
            }
        }
        
        sortedColors.sort()
        
        var curColor: UIColor
        for curContainer in sortedColors
        {
            curColor = curContainer.color
            if tempPC == nil
            {
                if curColor.isContrastingColor(backgroundColor)
                {
                    tempPC = curColor
                }
            }
            else if tempSC == nil
            {
                if !tempPC!.isDistinct(curColor) || !curColor.isContrastingColor(backgroundColor)
                {
                    continue
                }
                tempSC = curColor
            }
            else if tempDC == nil
            {
                if !tempSC!.isDistinct(curColor) || !tempPC!.isDistinct(curColor) || !curColor.isContrastingColor(backgroundColor)
                {
                    continue
                }
                tempDC = curColor
                return (primaryColor: tempPC, secondaryColor: tempSC, detailColor: tempDC)
            }
        }
        return (primaryColor: tempPC, secondaryColor: tempSC, detailColor: tempDC)
    }
}

struct Pixel: Equatable {
    fileprivate var rgba: UInt32
    
    var red: UInt8 {
        return UInt8((rgba >> 24) & 255)
    }
    
    var green: UInt8 {
        return UInt8((rgba >> 16) & 255)
    }
    
    var blue: UInt8 {
        return UInt8((rgba >> 8) & 255)
    }
    
    var alpha: UInt8 {
        return UInt8((rgba >> 0) & 255)
    }
    
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
}

func ==(lhs: Pixel, rhs: Pixel) -> Bool {
    return lhs.rgba == rhs.rgba
}

struct CountedColor: Comparable
{
    let color: UIColor
    var count: Int
}

func ==(lhs: CountedColor, rhs: CountedColor) -> Bool
{
    return lhs.count == rhs.count
}

func <(lhs: CountedColor, rhs: CountedColor) -> Bool
{
    return lhs.count < rhs.count
}

extension UIColor
{
    var isDarkColor: Bool
    {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  lum < 0.47 ? true : false
    }
    
    var isBlackOrWhite: Bool
    {
        guard let tempColor = Optional(self) else { return false }
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        tempColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        if r > 0.91 && g > 0.91 && b > 0.91 { return true }
        if r < 0.09 && g < 0.09 && b < 0.09 { return true }
        return false
    }
    
    func isContrastingColor(_ foregroundColor: UIColor?) -> Bool
    {
        let backgroundColor = Optional(self)
        if backgroundColor != nil && foregroundColor != nil
        {
            var br, bg, bb, ba, fr, fg, fb, fa: CGFloat
            (br, bg, bb, ba) = (0, 0, 0, 0)
            (fr, fg, fb, fa) = (0, 0, 0, 0)
            
            backgroundColor?.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
            foregroundColor?.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
            
            let bLum = 0.2126 * br + 0.7152 * bg + 0.0711 * bb
            let fLum = 0.2126 * fr + 0.7152 * fg + 0.0722 * fb
            
            var contrast: CGFloat
            if bLum > fLum
            {
                contrast = (bLum + 0.05) / (fLum + 0.05)
            }
            else
            {
                contrast = (fLum + 0.05) / (bLum + 0.05)
            }
            
            return contrast > 1.6
        }
        return true
    }
    
    func isDistinct(_ compareColor: UIColor) -> Bool
    {
        var r, g, b, a, r1, g1, b1, a1: CGFloat
        (r, g, b, a)     = (0, 0, 0, 0)
        (r1, g1, b1, a1) = (0, 0, 0, 0)
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        compareColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        let threshold: CGFloat = 0.25
        
        if abs(r - r1) > threshold || abs(g - g1) > threshold || abs(b - b1) > threshold || abs(a - a1) > threshold
        {
            if abs(r - g) < 0.03 && abs(r - b) < 0.03
            {
                if abs(r1 - g1) < 0.03 && abs(r1 - b1) < 0.03
                {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    func colorWithMinimumSaturation(_ minSaturation: CGFloat) -> UIColor
    {
        if let tempColor = Optional(self)
        {
            var hue:CGFloat        = 0.0
            var saturation:CGFloat = 0.0
            var brightness:CGFloat = 0.0
            var alpha:CGFloat      = 0.0
            tempColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            if saturation < minSaturation
            {
                return UIColor(hue: hue, saturation: minSaturation, brightness: brightness, alpha: alpha)
            }
        }
        return self
    }
}
